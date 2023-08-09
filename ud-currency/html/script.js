window.addEventListener('message', function(event) {
    const cashStatusDiv = document.getElementById("cashStatus");
    const cashAmountDiv = document.getElementById("cashAmount");
    const cashIconDiv = document.getElementById("cashIcon");
    
    if(event.data.action == "updateCash") {
        cashAmountDiv.innerHTML = "$" + event.data.cash;

        cashIconDiv.style.display = "inline";
        cashStatusDiv.classList.remove("hidden");
        
        setTimeout(function() {
            cashIconDiv.style.display = "none";
            cashAmountDiv.innerHTML = "";
            cashStatusDiv.classList.add("hidden");
        }, 5000);
    }
});
