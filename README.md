# Gleepost !

## Documentation

Regenerate the core data model using mogeneretor. 

1. You need first to download and install the tool
2. Run `mogenerator -m messaging/messaging.xcdatamodeld -O messaging/Model --template-var arc=true`
3. Add any new generated files to the Model group folder

Note: Each entities in core data must have a custom class with the same name than the name of the entity.
