json.(tag,
	:id,
	:name,
)
json.count( @tag_count[tag.id] )
if tag.link 
	json.link( tag.link, :uri )
else
	json.link( nil )
end
