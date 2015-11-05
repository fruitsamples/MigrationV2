MigrationV2

This example demonstrates how to use the CoreData store migration 
feature to automatically update a CoreData store saved using one model
version to one that can be accessed using another model. It is based
on the Migration example that is included as part of the CoreRecipes
example (http://developer.apple.com/samplecode/CoreRecipes/), which 
shows how to do a data migration manually.

This example shows the following types of transformations:

1) adding attributes (and populating them with default data)
2) removing attributes
3) splitting attribute data across multiple fields
4) adding new entities
5) normalizing data out of existing entities into those new entities
6) modifying relationship types
7) modifying the runtime model to facilitate migration
8) using store metadata to track model version

The migration is done automatically when the Migrator application attempts to
open a store saved with an older model. Most transformations do not require code
and are completely specified in the mapping model (MappingModel.xcmappingmodel). 
Entity normalization and attribute transformation require some code 
(MigrationFunctions.h, CuisineMigrationPolicy.h) in addition to the mapping model.

MigrationV2 contains three targets:

Generator - this builds a simple data generator which can be used 
to populate a database which can then be migrated using

Migrator - this builds the app which does the migration. This migration 
is done automatically, and is initiated by setting a migration policy
(RecipesStoreMigrationPolicy.h) in the options dictionary passed to 
addPersistentStoreWithType:configuration:URL:options:error: when a store
is added.

Build All - build both Generator and Migrator.

You may incorporate sample code from these examples into your applications 
without restriction, although the sample code has been provided "as is" and 
the responsibility for its operation is completely yours. However, you should 
not redistribute the source as "Apple Sample Code" if you make changes to it. 
If you're going to re-distribute the source, we require that you make it clear 
in the source that, although the code derived from Apple Sample Code,  you've 
since made changes to it.