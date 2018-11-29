var nbDays = 30;

var d = new Date();
d.setDate(d.getDate() - nbDays);
d.setUTCHours(0, 0, 1);

var orderIdList = [];

db.Order.find({
    createdAt: { $gte: new Date(d) },
    status: { $in: ['paid', 'canceled', 'cancelled'] }
}, { _id: 1 }).forEach(function(doc) {
    // Check there is at least one OrderProduct linked to this order
    var nbOrderProduct = db.OrderProduct.count({ "orderId": doc["_id"] });

    if (nbOrderProduct > 0) {
        orderIdList.push(doc['_id']);
    }
});

var myCursor = db.Order.aggregate([
    {
        "$match": {
            _id: { $in: orderIdList }
        }
    },
    {
        "$sort": { "createdDate": -1 }
    },
    {
        "$project": {
            "_id": 1,
            "status": 1,
            "createdAt": 1,
            "date": {
                "$dateToString": {
                    "format": "%Y-%m-%dT%H:%M:%SZ",
                    "date": "$createdAt"
                }
            }
        }
    },
    {
        "$group": {
            "_id" : {
                year: { $year: "$createdAt" },
                month: { $month: "$createdAt" },
                day: { $dayOfMonth: "$createdAt" },
                hour: { $hour: "$createdAt" }
            },
            "nbOrders": { $sum: 1 },
            "date": { $first: "$date" }
        }
    }
]);

var result = {
    "update": new Date().toJSON(),
    "from": d.toJSON(),
    "to": new Date().toJSON(),
    "nbDays": nbDays,
    "data": myCursor.toArray()
};

printjson(result);