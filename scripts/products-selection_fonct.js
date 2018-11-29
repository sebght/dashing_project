var nbDays = 65;

var from = new Date();
from.setDate(from.getDate() - nbDays);
from.setUTCHours(0, 0, 1);

var to = new Date();
to.setDate(to.getDate());
to.setUTCHours(23, 59, 59);

var from2 = new Date();
from2.setDate(from2.getDate() - 1);
from2.setUTCHours(0, 0, 1);

var lastaccepted = [];
db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from2), $lte: new Date(to) },
            "history.toState": "accepted",
        }
    },
    {
        "$sort": { "history.date": -1 }
    },
    {
        "$project": {
            "_id": 1,
        }
    },
    {
        "$limit":1
    
    }
]).forEach(function(doc) {
    lastaccepted.push(doc['_id']);
});

var lastmediaId = db.Product.aggregate([
    {
        "$unwind" : "$assets"
    },
    {
        "$match": {
            "_id": {
                "$in": lastaccepted
            },
            "assets.role":"MAIN_PICTURE"
        }
    },
    {
        "$project": {
            "_id": 1,
            "assetsmedia":"$assets.mediaId"
        }
    }
]);

var rejectedProducts = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "rejected"
        }
    },
    {
        "$project": {
            "_id": 1,
            "historyDate": "$history.date",
            "date": {
                "$dateToString": {
                    "format": "%Y-%m-%dT%H:%M:%SZ",
                    "date": "$history.date"
                }
            }
        }
    },
    {
        "$group": {
            "_id" : {
                day: { $dayOfMonth: "$historyDate" },
                month: { $month: "$historyDate" },
                year: { $year: "$historyDate" }
            },
            "count": { $sum: 1 },
            "date": { $last: "$date" }
        }
    }
]);

var awaitingchangesProducts = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "awaiting_changes"
        }
    },
    {
        "$project": {
            "_id": 1,
            "historyDate": "$history.date",
            "date": {
                "$dateToString": {
                    "format": "%Y-%m-%dT%H:%M:%SZ",
                    "date": "$history.date"
                }
            }
        }
    },
    {
        "$group": {
            "_id" : {
                day: { $dayOfMonth: "$historyDate" },
                month: { $month: "$historyDate" },
                year: { $year: "$historyDate" }
            },
            "count": { $sum: 1 },
            "date": { $last: "$date" }
        }
    }
]);

var pendingexpProducts = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "pending_expertize"
        }
    },
    {
        "$project": {
            "_id": 1,
            "historyDate": "$history.date",
            "date": {
                "$dateToString": {
                    "format": "%Y-%m-%dT%H:%M:%SZ",
                    "date": "$history.date"
                }
            }
        }
    },
    {
        "$group": {
            "_id" : {
                day: { $dayOfMonth: "$historyDate" },
                month: { $month: "$historyDate" },
                year: { $year: "$historyDate" }
            },
            "count": { $sum: 1 },
            "date": { $last: "$date" }
        }
    }
]);


var pendingExp_pending = [];
db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.toState": "pending_expertize",
        }
    },
    {
        "$project": {
            "_id": 1,
        }
    }
]).forEach(function(doc) {
    pendingExp_pending.push(doc['_id']);
});

var pendingExpAccepted = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "accepted",
            "_id": {
                "$in": pendingExp_pending
            }
        }
    },
    {
        "$project": {
            "_id": 1,
            "historyDate": "$history.date",
            "date": {
                "$dateToString": {
                    "format": "%Y-%m-%dT%H:%M:%SZ",
                    "date": "$history.date"
                }
            }
        }
    },
    {
        "$group": {
            "_id" : {
                day: { $dayOfMonth: "$historyDate" },
                month: { $month: "$historyDate" },
                year: { $year: "$historyDate" }
            },
            "count": { $sum: 1 },
            "date": { $last: "$date" }
        }
    }
]);

var statusProducts = db.Product.aggregate([
    {
        "$match": {
             status: {
                "$in": [
                    "pending_review",
                    "awaiting_crop",
                ]
            },
            }
    },
    {
        "$project": {
            "_id": 1,
            "status":1,
            
        }
    },
    {
        "$group": {
            _id: "$status",
            count: {
                "$sum": 1,
            }
        }
    }
]);

var newpinnedProducts = db.Product.aggregate([
    {
        "$match": {
            "flags.isNewFavorite": {$eq: true},
            }
    },
    {
        "$project": {
            "_id": 1,
            
        }
    },
    {
        "$group": {
            _id: null,
            count: {
                "$sum": 1,
            }
        }
    }
]);

var result = {
    "update": new Date().toJSON(),
    "from": from.toJSON(),
    "to": to.toJSON(),
    "lastmediaId":lastmediaId.toArray(),
    "rejectedProducts": rejectedProducts.toArray(),
    "awaitingchangesProducts":awaitingchangesProducts.toArray(),
    "pendingexpProducts":pendingexpProducts.toArray(),
    "newpinnedProducts":newpinnedProducts.toArray(),
    "statusProducts":statusProducts.toArray(),
    "pendingExpAccepted":pendingExpAccepted.toArray()
};

printjson(result);