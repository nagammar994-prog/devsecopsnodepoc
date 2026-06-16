const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {

    const password = "admin123";

    let data = null;

    if (data == undefined) {
        console.log("Data missing");
    }

    res.json({
        username: "demo",
        password: password
    });
});

module.exports = router;
