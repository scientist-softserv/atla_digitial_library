class RightsStatementLookup
  def self.subauthority_filename
    File.join(Qa::Authorities::Local.subauthorities_path, "rights_statements.yml")
  end

  def self.subauthority_hash
    @@subauthority_hash ||= YAML.load(File.read(subauthority_filename))
  end

  def self.description_for(id)
    subauthority_hash['terms'].detect { |statement|
      statement["id"].gsub(/http(s{0,1}):\/\//, '').chomp('/') == id.gsub(/http(s{0,1}):\/\//, '').chomp('/')
    }&.[]("description")&.to_s&.html_safe
  end
end
