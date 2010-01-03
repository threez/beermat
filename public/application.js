var person_id = false,   drink_id = false,
    person_name = false, drink_name = false
    
function check_if_new_entry() {
  if (person_name && person_id && drink_name && drink_id) {
    question = "Hat " + person_name + " folgendes getrunken: " + drink_name;
    if (confirm(question)) {
      window.location.href = "/" + person_id + "/protocol/" + drink_id;
    }  
    person_name = person_id = drink_name = drink_id = false;
  }
}

$(function() {
  $("tr.person .identity a").live("click", function() {
    person_name = $(this).find(".person_name").html();
    person_id = this.hash.replace("#", "");
    check_if_new_entry();
    return false;
  })
  $("a.drink").live("click", function() {
    drink_name = $(this).find(".drink_name").html();
    drink_id = this.hash.replace("#", "");
    check_if_new_entry();
    return false;
  })
})