xml.person do
  xml.id(person.id, :type => 'integer')
  xml.fullname(person.fullname)
end