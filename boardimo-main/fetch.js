let btn = document.getElementById("fetch");

btn.addEventListener("click", function () {
  let url = document.getElementById("url-fetch").value;

  fetch('http://localhost:7373/get-info', {
      mode: "no-cors",
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        url: url
      })
    })
    .then(response => response)
    .then(data => {
      console.log(data)
    })
});