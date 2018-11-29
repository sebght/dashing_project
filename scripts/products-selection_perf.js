var nbDays = 65;

var from = new Date();
from.setDate(from.getDate() - nbDays);
from.setUTCHours(0, 0, 1);

var to = new Date();
to.setDate(to.getDate());
to.setUTCHours(23, 59, 59);

var awaitingchanges = [];
db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.toState": "awaiting_changes",
        }
    },
    {
        "$project": {
            "_id": 1,
        }
    }
]).forEach(function(doc) {
    awaitingchanges.push(doc['_id']);
});

var AWAcceptedProducts = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "accepted",
            "_id": {
                "$in": awaitingchanges
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

var pendingexp = [];
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
    pendingexp.push(doc['_id']);
});

var DesignedAcceptedProducts = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "accepted",
            "_id": {
                "$in": pendingexp
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

var pinnedProducts = db.Product.aggregate([
    {
        "$match": {
            "flags.isFavorite": {$eq: true},
        }
    },
    {
        "$project": {
            "_id": 1,
            "publishedAt": "$publishedAt",
            "date": {
                "$dateToString": {
                    "format": "%Y-%m-%dT%H:%M:%SZ",
                    "date": "$publishedAt"
                }
            }
        }
    },
    {
        "$group": {
            "_id" : {
                day: { $dayOfMonth: "$publishedAt" },
                month: { $month: "$publishedAt" },
                year: { $year: "$publishedAt" }
            },
            "count": { $sum: 1 },
            "date": { $last: "$date" }
        }
    }
]);

var pendingreviewResults = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "pending_review"
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

var rejectedResults = db.Product.aggregate([
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

var pinned = [];
db.Product.aggregate([
    {
        "$match": {
            "flags.isFavorite": {$eq: true},
        }
    },
    {
        "$project": {
            "_id": 1,
        }
    }
]).forEach(function(doc) {
    pinned.push(doc['_id']);
});

var GMVpinnedProducts = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "sold_out",
            "_id": {
                "$in": pinned
            }
        }
    },
    {
        "$project": {
            "_id": 1,
            "value":"$pricing.price.value",
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
            "date": { $last: "$date" },
            "value":{ $sum: "$value" },
        }
    }
]);

var acceptedProducts = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "accepted",
        }
    },
    {
        "$project": {
            "_id": 1,
            "value":"$pricing.price.value",
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
            "date": { $last: "$date" },
            "value":{ $sum: "$value" },
        }
    }
]);

var result = {
    "update": new Date().toJSON(),
    "from": from.toJSON(),
    "to": to.toJSON(),
    "AWAcceptedProducts": AWAcceptedProducts.toArray(),
    "DesignedAcceptedProducts": DesignedAcceptedProducts.toArray(),
    "pendingreviewResults":pendingreviewResults.toArray(),
    "rejectedResults":rejectedResults.toArray(),
    "pinnedProducts": pinnedProducts.toArray(),
    "GMVpinnedProducts": GMVpinnedProducts.toArray(),
    "acceptedProducts":acceptedProducts.toArray()
};

printjson(result);