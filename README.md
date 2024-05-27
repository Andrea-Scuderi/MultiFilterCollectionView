# Creating a Multi-Filter Collection View with Diffable Data Source

This example was used as a proof of concept on iOS for creating a complex user interface in a collection view. 

Requirements:
- The users can select only one category on the first carousel. There is always a default category selected.
- Once a category is selected, the second carousel will show all the available options and the user can select multiple options.
- Multiple sections are added to the collection view reflecting the choices made on the first and the second carousel allowing choices between items.

This tutorial will guide you through creating a collection view with multiple filterable sections using `UICollectionViewDiffableDataSource` and `UICollectionViewCompositionalLayout`.

![Multi-Filter Collection View](MultiFilterCollectionViewDemo.mov)