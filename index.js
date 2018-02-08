'use strict';

const express = require('express');
const PORT = 8080;
const HOST = '0.0.0.0';
const MongoClient = require('mongodb').MongoClient;
const test = require('assert');
const url = 'mongodb://mongo:27017';
const dbName = 'test';


// App
const app = express();
app.get('/', (req, res) => {
    MongoClient.connect(url, function(err, client) {
    // Use the admin database for the operation
        const adminDb = client.db(dbName).admin();
        // List all the available databases
        adminDb.listDatabases(function(err, dbs) {
            test.equal(null, err);
            test.ok(dbs.databases.length > 0);
            client.close();
            res.send({dbs: dbs.databases.length});
        });
    });

});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);