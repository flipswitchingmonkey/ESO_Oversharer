# ESO_Oversharer

**Oversharer** came to be after guild members asked for a way to see when guild members picked up and finished daily quests, pledges etc. as part of guild events or just to find someone else to do a particularly exciting (or boring) quest with.

The addon listens to when you accept, abandon or complete a quest and lets your guild members (if they also run the addon) know that you did so, and when.

Since addons are not allowed to communicate directly with other players, I had to fall back on a workaround. It's not pretty, but it does the job...
To communicate, the addon will generate a short string that contains the quest information. It will then inject that string into your guild member note. This, in turn, will trigger an event for your other guild members, whose addon will then read that note and that's that.
The addon should not touch what's already in your note (ideally), but no guarantees are given here! It _should_ never change anything else, but it _may_ well do so. So be warned.

Note: it is required that you are allowed to edit your guild note and read others guild notes within your guild. If you only want to receive messages, read permissions are enough.

Commands:
/oversharer - will show the main window

You can also set a shortcut through the ESO control settings.
