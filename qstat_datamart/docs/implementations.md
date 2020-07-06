# the different implentation variants

The folder models/datamart contains two variants.
Each variant resides in its own folder and has its own release number.

## var1_staging_based

As the name suggests this implementation is based of the staging area, specifically the XMLINTERFACE* tables in the db schema ```staging```.

See the sources.yml in the models/staging folder.

All tables bear the assigned version number v1.0.1 in their names.

## var1_coredv_based

This implementation is based on the DataVault create with the DVB,
which provides access via views in the db schema ```accesslayer```.
As it provides more functionality it is implementated as v1.1.1,
following the principles of semantic versioning.

Note: there was a v1.1.0, that has been discard early on.

The used tables are described in ```accesslayer_sources.yml```.
There the layer is named ```DV-AL``` for a convenient use in the jinja templates.

