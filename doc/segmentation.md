# Adding Custom Segmentation Characteristics

First off, Phil did a nice job of making this whole thing easily extensible. But in order to keep YOUR segmentation working smoothly with other segments, you will want to follow the pattern that Phil has set up. 

## Dummy Characteristics are Key

If you look around for other "dummy characteristics" in the code, you will see how to segment

## Notes on using two databases in one Rails app. 

Note that all our segmentation happens as a subclass of User. That is, in the app/models/user directory you will see all the models that exist in Mongo.

Both Postgres and Mongo models exist alongside one another in the rails console. That is, from the rails console you can call
    User.count
(A postgres call)
Or you can call 
    User::SegmentationData.where(ar_id: [15,20,25])
(A mongo call)
For more details, you can read up on Mongoid, which is the library we use to access mongo, but queries work almost exactly the same 

## The General Pattern

All of the traits that we are using Mongo to segment on actually exist in Postgres. That is, postgres is the mother that contains all the real data. The Mongo database can be generated from the Postgres database at any time. So to get your special segmentation characteristic working, you just need to:

1. Create a new field on the user model in postgres
1. Update that new field when the right thing happens
1. Put a callback on the user model that schedules an update of the corresponding record in Mongo

The first two in that list you are probably already familiar with. To set up a callback to the Mongo db, see the next section

## Callbacks That Save to Mongo

First, add your characteristic to the FIELDS_TRIGGERING_SEGMENTATION_UPDATE constant in user.rb. This means stuff will be shipped to mongo when your trait is updated. 
Then in app/models/user/segmentation.rb:6, update 
    User#values_for_segmentation
which is the big hash that will actually be shipped off to Mongo. 

## Make it Visible on the Admin Dashboard as a Segmentation Characteristic
and finally, you'll need a "dummy characteristic" to make that timestamp actually appear as an option in the segmentation interface. To do this, open app/models/dummy_characteristic.rb and look near lines 25-35. Just add to this array the name and datatype of your characteristic, and it will be available on the admin dashboard segmentation page.


