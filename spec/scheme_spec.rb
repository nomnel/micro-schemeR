files = Dir.glob("#{File.join(__dir__, '..')}/*.rb")
files.each { |f| require f }
main = self

describe '_eval' do
  it 'can addition, subtraction, and multiplication' do
    expect(_eval [:+, 2, 1]).to eq 3
    expect(_eval [:-, 2, 1]).to eq 1
    expect(_eval [:*, 2, 1]).to eq 2
  end
end

describe 'list?' do
  it 'determines arg is a list or not' do
    expect(list? [1]).to be true
    expect(list? 1).to be false
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

describe 'immediate_val?' do
  it 'determines arg is a immediate value or not' do
    expect(immediate_val? 1).to eq true
    expect(immediate_val? 'a').to eq false
    expect(immediate_val? [1]).to eq false
  end
end