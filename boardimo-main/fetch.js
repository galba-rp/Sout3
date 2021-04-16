let btn = document.getElementById("fetch");

btn.addEventListener("click", function () {
  let url = document.getElementById("url-fetch").value;

  fetch('http://localhost:7373/get-info', {
      // mode: "cors",
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'text/plain;charset=UTF-8'
      },
      body: JSON.stringify({
        url: url
      })
    })
    .then(response => response.json())
    .then(data => {
      results = document.getElementById("results");
      form = results.children[1];
      price = new Intl.NumberFormat('fr-FR', {
        style: 'decimal',
        currency: 'EUR',
      }).format(data.price) + ' €';
      info = form.lastElementChild.firstElementChild.children
      comparePrice = data.price / data.surface > data.avgPrice ? "inférieur" : "supérieur"
      compareYear = data.avgYear > 0 ? "est plus récente" : "est plus ancienne"
      moreLess = data.avgYear > 0 ? "moins" : "plus"
      moreLessSaving = data.renovSaving < 0 ? "moins" : "plus"
      betterWorse = data.energyCost > 0 ? "moins bien que" : "mieux que"

      if (data.price / 1000 < data.priceRangeLow) {
        evaluation = 'sous-évaluée'
      } else if (data.price / 1000 >= data.priceRangeLow && data.price / 1000 <= data.priceRangeHigh) {
        evaluation = 'au juste prix'
      } else {
        evaluation = 'surévaluée'
      }

      results.firstElementChild.firstElementChild.setAttribute('src', data.img);
      results.firstElementChild.firstElementChild.classList.remove("d-none")

      form.querySelector('h1').innerHTML = data.title;
      form.firstElementChild.querySelector('div').innerHTML = price;
      form.lastElementChild.firstElementChild.children

      info[0].innerHTML = data.surface + ' m²';
      info[1].innerHTML = data.year;
      info[2].innerHTML = data.energy;

      document.getElementsByClassName('price')[0].innerText = "Prix par m² " + Math.round(data.price / data.surface) + "€";
      document.getElementById('priceBlock').style.backgroundColor = data.priceColor;
      document.getElementById('avgSqMerter').innerHTML = "À " + data.cityName + ", le prix moyen d'une maison au m² est de <b>" + data.avgPrice + "€ </b> soit " + data.difference + " % " + comparePrice + " au prix de ce bien."
      document.getElementById('yearBlock').style.backgroundColor = data.yearColor;
      document.getElementById('yearBlock').children[1].innerHTML = "Cette maison <b>est plus récente que " + data.moreRecentPercent + "%</b> des maisons en vente actuellement et a en moyenne <b> " + data.avgYear + " ans de " + moreLess + " que la concurrence "
      document.getElementById('yearBlock').children[3].innerHTML = "Suite à un achat de ce type, un acquereur dépensera en moyenne <b> " + (data.renovCost + data.renovSaving) + "€ de rénovations en tout genre</b> soit <b> " + Math.abs(data.renovSaving) + "€ de " + moreLessSaving + " </b> que la moyenne pour cette surface"
      document.getElementById('energyBlock').style.backgroundColor = data.energyColor;
      document.getElementById('energyBlock').children[1].innerHTML = "Cette maison a une <b>classe énergétique " + data.energy + " </b> ce qui est <b>" + betterWorse + " " + data.energyPercent + " % </b>des maisons en vente actuellement";
      document.getElementById('energyBlock').children[3].innerHTML = (data.energyCost > 0 ? 'Le surcoût' : 'Les économies') + " énergétique par m2 est estimé à " + Math.abs(data.energyCost) + "€"
      document.getElementById('estimBlock').style.backgroundColor = data.estimColor;
      document.getElementById('estimBlock').children[1].innerHTML = "En prenant en compte l'année de construction, la localisation et le prix au m2 nous pensons que cette maison est " + evaluation + "."
      document.getElementById('estimBlock').children[3].innerHTML = "Afin de correspondre au prix du marché nous évaluons que le prix de ce bien devrait se situer entre <b> " + data.priceRangeLow + "k€</b> et <b>" + data.priceRangeHigh + "k€</b>"
      console.log(data)
    })
});