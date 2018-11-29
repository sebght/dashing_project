var nbDays = 65;

var from = new Date();
from.setDate(from.getDate() - nbDays);
from.setUTCHours(0, 0, 1);

var to = new Date();
to.setDate(to.getDate());
to.setUTCHours(23, 59, 59);

var productResults = db.Product.aggregate([
    {
        "$unwind" : "$history"
    },
    {
        "$match": {
            "history.date": { $gte: new Date(from), $lte: new Date(to) },
            "history.toState": "accepted"
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

var result = {
    "update": new Date().toJSON(),
    "from": from.toJSON(),
    "to": to.toJSON(),
    "data": productResults.toArray()
};

printjson(result);