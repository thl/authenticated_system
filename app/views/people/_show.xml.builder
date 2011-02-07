xml.person do
  xml.id(person.id, :type => 'integer')
  xml.fullname(person.fullname)
  xml.created_at(person.created_at, :type => 'datetime')
  xml.updated_at(person.updated_at, :type => 'datetime')
end