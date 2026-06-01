const express = require("express");

const app = express();

app.get("/", (req, res) => {
    res.send("DevSecOps POC");
});

app.get("/health", (req, res) => {
    res.status(200).json({
        status: "healthy"
    });
});

app.listen(3000, () => {
    console.log("Server started");
});
