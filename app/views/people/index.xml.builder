xml.instruct!
xml.people(:type => 'array') do
  @people.each{ |person| xml << render(:partial => 'show', :locals => {:person => person}) }
end