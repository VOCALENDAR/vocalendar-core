json.(tag,
	:id,
	:name,
)
json.count( tag.events.count )
json.link( ExLink.where( id: tag.id ).first.uri )
