xml.people(:type => 'array') do
  for person in people
    xml << render(:partial => 'show', :locals => {:person => person})
  end
end