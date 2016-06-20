
class ContractFromDataRow
  attr_reader :organizations, :attrs,  :columns, :row_data

  def initialize designer, columns
    @organization = organization
    @columns = columns
  end

  def create row_data
    @row_data = row_data
    @attrs = parse_attributes
    @contract = new_contract
  end

  def parse_attributes
    h = {}
    columns.each do |k, v|
      h[v]=row_data[k]
    end
    h
  end

  def new_contract
    organization.contracts.build(attrs)
  end

end
