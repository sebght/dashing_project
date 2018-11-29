var nbDays = 65;

var from = new Date();
from.setDate(from.getDate() - nbDays);
from.setUTCHours(0, 0, 1);

var to = new Date();
to.setDate(to.getDate());
to.setUTCHours(23, 59, 59);

var orderIdList = [];

// Get list of paid orders, in date range
db.Order.aggregate([
    {
        "$match": {
            status: { $in: ['paid', 'canceled', 'cancelled'] },
            createdAt: { $gte: new Date(from), $lte: new Date(to) }
        }
    },
    {
        "$sort": { "createdDate": -1 }
    },
    {
        "$project": { "_id": 1 }
    }
]).forEach(function(doc) {
    orderIdList.push(doc["_id"]);
});

// Now get list of ordered products linked to these orders
var orderProductCursor = db.OrderProduct.aggregate([
    {
        "$match": {
            "orderId": { $in: orderIdList }
        }
    },
    {
        "$project": {
            _id: 1,
            price: "$price.value",
            split: 1,
            createdAt: 1,
            product: 1,
            date: {
                "$dateToString": {
                    "format": "%Y-%m-%dT%H:%M:%SZ", "date": "$createdAt"
                }
            }
        }
    },
    {
        "$group": {
            "_id" : {
                day: { $dayOfMonth: "$createdAt" },
                month: { $month: "$createdAt" },
                year: { $year: "$createdAt" }
            },
            "total": { $sum: "$price" },
            "date": { $last: "$date" }
        }
    },
    {
        "$sort": { "date": 1 }
    }
]);

var result = {
    "update": new Date().toJSON(),
    "from": from.toJSON(),
    "to": to.toJSON(),
    "nbDays": nbDays,
    "data": orderProductCursor.toArray()
};

printjson(result);
