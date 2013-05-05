files = Dir.glob("#{File.join(__dir__, '..')}/*.rb")
files.each { |f| require f }
main = self

describe '_eval' do
  env = $global_env

  it 'can addition, subtraction, and multiplication' do
    expect(_eval [:+, 2, 1], env).to eq 3
    expect(_eval [:-, 2, 1], env).to eq 1
    expect(_eval [:*, 2, 1], env).to eq 2
  end

  it 'evaluates a lambda exp' do
    expect(_eval [[:lambda, [:x, :y], [:+, :x, :y]], 3, 2], env).to eq 5
  end

  it 'evaluates a let exp' do
    expect(_eval [:let, [[:x, 3], [:y, 2]], [:+, :x, :y]], env).to eq 5
  end

  it 'has a lexical scope' do
    exp = [:let, [[:x, 2]],
            [:let, [[:fun, [:lambda, [], :x]]],
              [:let, [[:x, 1]],
                [:fun]]]]
    expect(_eval exp, env).to eq 2
  end
end

describe 'list?' do
  it 'determines arg is a list or not' do
    expect(list? [1]).to be true
    expect(list? 1).to be false
  end
end

describe 'immediate_val?' do
  it 'determines arg is a immediate value or not' do
    expect(immediate_val? 1  ).to eq true
    expect(immediate_val? 'a').to eq false
    expect(immediate_val? [1]).to eq false
  end
end

describe 'num?' do
  it 'determines arg is a numeric or not' do
    expect(num? 1  ).to eq true
    expect(num? 'a').to eq false
  end
end

describe 'lookup_var' do
  env = [{a: 1}, {a: 2, x: 3}]

  it 'returns a value of var if var is in environment' do
    expect(lookup_var :x, env).to eq 3
  end

  it 'raises a error if var is not in environment' do
    expect{lookup_var :y, env}.to raise_error
  end
end

describe 'special_form?' do
  it 'determines exp is in [lambda, let,letrec, if] or not' do
    lambda_exp = [:lambda, [:x, :y], [:+, :x, :y]]
    let_exp    = [:let, [[:x, 3], [:y, 2]], [:+, :x, :y]]
    letrec_exp = [:letrec, [[:fn, [:lambda, [:n], :fn]]], [:fn]]
    if_exp     = [:if, [:>, 3, 2], 1, 0]

    expect(special_form? lambda_exp).to eq true
    expect(special_form? let_exp   ).to eq true
    expect(special_form? letrec_exp).to eq true
    expect(special_form? if_exp    ).to eq true
    expect(special_form? []        ).to eq false
  end
end

describe 'lambda?' do
  it 'determines exp is a lambda-exp or not' do
    lambda_exp = [:lambda, [:x, :y], [:+, :x, :y]]
    let_exp    = [:let, [[:x, 3], [:y, 2]], [:+, :x, :y]]

    expect(lambda? lambda_exp).to eq true
    expect(lambda? let_exp   ).to eq false
  end
end

describe 'let?' do
  it 'determines exp is a let-exp or not' do
    let_exp    = [:let, [[:x, 3], [:y, 2]], [:+, :x, :y]]
    lambda_exp = [[:lambda, [:x, :y], [:+, :x, :y]], 3, 2]

    expect(let? let_exp   ).to eq true
    expect(let? lambda_exp).to eq false
  end
end

describe 'if?' do
  it 'determines exp is a if_exp or not' do
    if_exp  = [:if, [:>, 3, 2], 1, 0]
    let_exp = [:let, [[:x, 3], [:y, 2]], [:+, :x, :y]]

    expect(if? if_exp ).to eq true
    expect(if? let_exp).to eq false
  end
end

describe 'letrec?' do
  it 'determines exp is a letrec_exp or not' do
    letrec_exp  = [:letrec, [[:x, 3], [:y, 2]], [:+, :x, :y]]
    let_exp     = [:let, [[:x, 3], [:y, 2]], [:+, :x, :y]]

    expect(letrec? letrec_exp).to eq true
    expect(letrec? let_exp   ).to eq false
  end
end

describe 'eval_lambda' do
  it 'makes closure that has params, body, and env' do
    params = [:x, :y]
    body   = [:+, :x, :z]
    env    = [{z: 1}]

    expect(eval_lambda [:lambda, params, body], env).to \
      eq [:closure, params, body, env]
  end
end

describe 'make_closure' do
  it 'makes closure that has params, body, and env' do
    params = [:x, :y]
    body   = [:+, :x, :z]
    env    = [{z: 1}]

    expect(make_closure [:lambda, params, body], env).to \
      eq [:closure, params, body, env]
  end
end

describe 'eval_let' do
  it 'is syntax sugar of lambda exp' do
    let_exp    = [:let, [[:x, 3], [:y, 2]], [:+, :x, :y]]
    lambda_exp = [[:lambda, [:x, :y], [:+, :x, :y]], 3, 2]
    env        = $global_env

    expect(eval_let let_exp, env).to eq _eval lambda_exp, env
  end
end

describe 'let_to_parameters_args_body' do
  it 'deconstructs let-exp to [params, args, body]' do
    let_exp          = [:let, [[:x, 3], [:y, 2]], [:+, :x, :y]]
    params_args_body = [[:x, :y], [3, 2], [:+, :x, :y]]

    expect(let_to_parameters_args_body let_exp).to eq params_args_body
  end
end

describe 'eval_letrec' do
  it 'can apply binded variables recursively' do
    exp = [:letrec,
            [[:fact,
              [:lambda, [:n], [:if, [:<, :n, 1], 1, [:*, :n, [:fact, [:-, :n, 1]]]]]]],
              [:fact, 3]]
    expect(eval_letrec exp, $global_env).to eq 6
  end
end

describe 'set_extend_env!' do
  it 'sets values to dummy data of env' do
    params = [:x, :y]
    args   = [3, 2]
    env    = [{x: :dummy, y: :dummy}] + $global_env
    set_extend_env! params, args, env
    expected_env = [{x: 3, y: 2}] + $global_env

    expect(env).to eq expected_env
  end
end

describe 'letrec_to_parameters_args_body' do
  it 'deconstructs letrec_exp to [params, args, body]' do
    letrec_exp       = [:letrec, [[:x, 3], [:y, 2]], [:+, :x, :y]]
    params_args_body = [[:x, :y], [3, 2], [:+, :x, :y]]

    expect(letrec_to_parameters_args_body letrec_exp).to eq params_args_body
  end
end

describe 'eval_if' do
  it 'evaluates true_clause if cond is truth, false_clause if not' do
    expect(eval_if [:if, [:>, 3, 2], 1, 0], $global_env).to eq 1
    expect(eval_if [:if, [:<, 3, 2], 1, 0], $global_env).to eq 0
  end
end

describe 'if_to_cond_true_false' do
  it 'deconstructs if_exp to [cond, true_clause, false_clause]' do
    if_exp   = [:if, [:>, 3, 2], 1, 0]
    expected = [[:>, 3, 2], 1, 0]

    expect(if_to_cond_true_false if_exp).to eq expected
  end
end

describe 'car' do
  it 'returns first value of array' do
    expect(car [1, 2, 3]).to eq 1
  end
end

describe 'cdr' do
  it 'returns values of array except first' do
    expect(cdr [1, 2, 3]).to eq [2, 3]
  end
end

describe 'eval_list' do
  it 'evals each exp of list' do
    exp = [[:+, 3, 2], [:*, 2, 1]]

    expect(eval_list exp, $global_env).to eq [5, 2]
  end
end

describe 'apply' do
  args = [1, 2]

  it 'evaluates a primitive function' do
    fun = [:prim, ->(x, y) {x + y}]

    expect(apply fun, args).to eq 3
  end

  it 'evaluates a closure' do
    env = [{x: 1, y: 2}] + $global_env
    fun = [:closure, [:x, :y], [:+, :x, :y], env]

    expect(apply fun, args).to eq 3
  end
end

describe 'primitive_fun?' do
  it 'determines exp is a primitive or not' do
    expect(primitive_fun? [:prim, ->(x, y) {x + y}]).to eq true
    expect(primitive_fun? [:lambda, [:x, :y], [:+, :x, :y]]).to eq false
  end
end

describe 'apply_primitive_fun' do
  it 'evaluates primitive function and args' do
    fun  = [:prim, ->(x, y) {x + y}]
    args = [1, 2]

    expect(apply_primitive_fun fun, args).to eq 3
  end
end

describe 'lambda_apply' do
  it 'evaluates closure with args' do
    env     = [{x: 1}] + $global_env
    closure = [:closure, [:y], [:+, :x, :y], env]
    args    = [2]

    expect(lambda_apply closure, args).to eq 3
  end
end

describe 'closure_to_parameters_body_env' do
  it 'deconstructs closure to [params, body, env]' do
    params  = [:x, :y]
    body    = [:+, :x, :y]
    env     = [{x: 1, y: 2}] + $global_env
    closure = [:closure, params, body, env]

    expect(closure_to_parameters_body_env closure).to eq [params, body, env]
  end
end

describe 'extend_env' do
  it 'prepends new hash consisted params and args to env' do
    params   = [:a, :b]
    args     = [1, 2]
    env      = [{a: 3}]
    expected = [{a: 1, b: 2}, {a: 3}]

    expect(extend_env params, args, env).to eq expected
  end
end

describe 'chapter 3' do
  it 'can evaluates letrec and if' do
    exp = [:letrec,
            [[:fact,
              [:lambda, [:n], [:if, [:<, :n, 1], 1, [:*, :n, [:fact, [:-, :n, 1]]]]]]],
              [:fact, 3]]
    expect(_eval exp, $global_env).to eq 6
  end
end