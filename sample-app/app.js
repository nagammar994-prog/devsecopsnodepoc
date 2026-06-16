const express = require('express');
const _ = require('lodash');

const app = express();

app.get('/user', (req, res) => {

  const password = "admin123";

  let data = null;

  if (data == undefined) {
    console.log("Data missing");
  }

  res.send(password);
});

app.listen(3000);
