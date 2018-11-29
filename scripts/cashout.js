db.getMongo().setSlaveOk()

var erroredCashoutPaymentsIds = [];
db.CashoutPayment.aggregate([
    {
        "$match": {
            status: "error",
            // "recipient.isMarketplace": false,
        }
    },
    {
        "$project": {
            "_id": 1,
        }
    }
]).forEach(function(doc) {
    erroredCashoutPaymentsIds.push(doc['_id']);
});

var orderProductsTransferRequested = db.OrderProduct.aggregate([
    {
        "$match": {
            status: "TRANSFER_REQUESTED",
            "cashoutPayments.$id": {
                "$in": erroredCashoutPaymentsIds
            }
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

var cashoutPayments = db.CashoutPayment.aggregate([
    {
        "$match": {
            status: {
                "$in": [
                    "check_required",
                    "to_process",
                ]
            }
        }
    },
    {
        "$project": {
            _id: 1,
            status: 1,
            gateway: 1,
            value: "$amount.value",
        }
    },
    {
        "$group": {
            _id: "$status",
            count: {
                "$sum": 1
            },
            value: {
                "$sum": "$value"
            }
        }
    }
]);

var today = new Date();
today.setHours(0);
today.setMinutes(0);
today.setSeconds(0);

var cashoutPaymentsProcessedToday = db.CashoutPayment.aggregate([
    {
        "$match": {
            "history.toState": "processed",
            "history.date": {
                "$gte": today,
            }
        }
    },
    {
        "$project": {
            _id: 1,
            value: "$amount.value",
        }
    },
    {
        "$group": {
            _id: null,
            count: {
                "$sum": 1,
            },
            value: {
                "$sum": "$value"
            }
        }
    }
])

printjson({
    update: new Date().toJSON(),
    orderProductsTransferRequested: orderProductsTransferRequested.toArray(),
    cashoutPayments: cashoutPayments.toArray(),
    cashoutPaymentsProcessedToday: cashoutPaymentsProcessedToday.toArray(),
});
