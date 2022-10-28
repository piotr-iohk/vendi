# frozen_string_literal: true

RSpec.describe Vendi::Utils do
  before(:all) do
    @v = set_vendi
  end

  it 'as_ada' do
    expect(@v.as_ada(1_000_000_000)).to eq '1000 ₳'
    expect(@v.as_ada(1_000_000_020)).to eq '1000.00002 ₳'
    expect(@v.as_ada(1_000_000_004)).to eq '1000.000004 ₳'
    expect(@v.as_ada(1_000_000)).to eq '1 ₳'
    expect(@v.as_ada(14_103_040)).to eq '14.10304 ₳'
    expect(@v.as_ada(14_143_546)).to eq '14.143546 ₳'
    expect(@v.as_ada(145_600_000)).to eq '145.6 ₳'
    expect(@v.as_ada(145_600_001)).to eq '145.600001 ₳'
    expect(@v.as_ada(145_001_000)).to eq '145.001 ₳'
    expect(@v.as_ada(11_111)).to eq '0.011111 ₳'
    expect(@v.as_ada(1_001)).to eq '0.001001 ₳'
    expect(@v.as_ada(1_000)).to eq '0.001 ₳'
    expect(@v.as_ada(100)).to eq '0.0001 ₳'
    expect(@v.as_ada(10)).to eq '0.00001 ₳'
    expect(@v.as_ada(1)).to eq '0.000001 ₳'
  end

  it 'asset_name' do
    expect(@v.asset_name('LALALA')).to eq '4c414c414c41'
    expect(@v.asset_name('1')).to eq '31'
    expect(@v.asset_name('TestBudz')).to eq '546573744275647a'
  end

  it 'eventually' do
    expect(@v.eventually('Test') { true }).to eq true
  end
end
