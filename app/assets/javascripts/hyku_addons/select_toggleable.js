class SelectGroupToggle {
  groupSelector = "[data-toggle-group]"
  controlSelector = "[data-toggle-control]"

  constructor(){
    this.onLoad()
    this.registerListeners()
  }

  onLoad(){
    console.log("SelectGroupToggle.onLoad")

    // Can't seen to get this to work via triggering the change event
    $(this.controlSelector).each($.proxy(function(i, el){
      this.toggleSelectGroup($(el))
    }, this))
  }

  registerListeners(){
    console.log("SelectGroupToggle.registerListeners")

    $("body").on("toggle_group", this.onToggleGroupEvent.bind(this))
  }

  onToggleGroupEvent(_event, target){
    this.toggleSelectGroup(target)
  }

  toggleSelectGroup(target){
    console.log(`SelectGroupToggle.Receive Event: ${event.type}`)

    let val = target.val()
    $(this.groupSelector).hide()
    $(`${this.groupSelector}[data-toggle-group=${val}]`).show()
  }
}

