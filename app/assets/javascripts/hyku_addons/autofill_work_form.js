class AutofillWorkForm {
  constructor(){
    this.targetInputSelector = "select, input, textarea, checkbox, radio"
    this.buttonSelector = "#doi-autofill-btn"
    this.$button = $(this.buttonSelector)
    this.$form = this.$button.closest("form")
    this.arrayValuesLength = 0
    this.updatedFields = []
    this.logClass = "autofill-message"
    this.successMessage = "The following fields were auto-populated:"
    this.failureMessage = "The DOI entered did not return any data"
    this.errorMessage = "An error occured, the DOI might not be valid"
    this.fieldLabelAcronyms = { doi: "DOI", issn: "ISSN", eissn: "eISSN" }

    if (this.$button.length === 0) {
      return false
    }

    this.alterRequestFormat()
    this.registerListeners()

    // FIXME: Remove this
    // $("#generic_work_doi").val("10.7554/elife.47972")
    // this.$button.data("confirm", "")
    // this.$button.trigger("click")
  }

  // If we do not provide a JSON request, then we receive console errors returning JSON from the response.
  // Ideally, this would be done inside the button path generation, but it relies on a url_helper inside a gem.
  alterRequestFormat() {
    let href = this.$button.attr("href") || ""
    this.$button.attr("href", href + ".json")
  }

  registerListeners() {
    // We don't want to use the default alert error messages
    this.$button.off("ajax:error")

    this.$button.on("click", (_e) => { $(`.${this.logClass}`).remove() })
    $("body").on("ajax:success", this.buttonSelector, this.onSuccess.bind(this))
    $("body").on("ajax:error", this.buttonSelector, this.onError.bind(this))
  }

  onSuccess(_e, response) {
    this.response = response

    if ($.isEmptyObject(this.response.data)) {
      return this.logFailure();
    }

    // Switch to the description tab automatically
    $("[aria-controls='metadata']").click()
    $(".additional-fields").click()

    Object.entries(this.response.data).forEach(([field, value]) => {
      this.processField(field, value)
    })

    this.logSuccess()
  }

  onError() {
    let $titleMessage = $("<p/>", { text: this.errorMessage })
    let $wrapper = $("<div/>", { class: `${this.logClass} bg-danger` }).append($titleMessage)

    $wrapper.prependTo(this.$form)
  }

  // This method performs most of the heavy lifting. It accepts a field name, a value and the index for the element.
  // It will then try and workout the correct field to place the value within.
  //
  // Value could be:
  // an array of objects, each of which contains multiple subfields and their value,
  // an object of subfields and their values
  // a string / int value
  processField(field, value, index = 0) {
    if (this.isBlank(value)) {
      return false;
    }

    // Dealing with edgecases by checking for a specific method to process a field
    if (this[`process_${field}`]) {
      this[`process_${field}`](value, index)

    } else if ($.type(value) == "array") {
      this.arrayValuesLength = value.length

      $(value).each((i, val) => {
        // If we need to check JSON fields recursively
        if ($.type(val) == "object") {
          return this.processField(field, val, i)
        }

        this.setValue(field, val, i)
        this.wrapper(field).find('button.add').click()
      })

    } else if ($.type(value) == "object") {
      var $wrapper = this.wrapper(field, index)

      // This isn't using the normal setValue method because of the requirement to autofill nested groups of fields
      Object.entries(value).forEach(([childField, childValue]) => {
        $($wrapper.find($(this.inputSelector(childField))).find(this.targetInputSelector).get(0)).val(childValue)
      })

      // Don't create extra cloneable blocks unless we have more data to add
      if (index + 1 < this.arrayValuesLength) {
        $wrapper.find("[data-on-click=clone_parent]").trigger("click")
      } else {
        this.setUpdated(field)
      }
    } else {
      this.setValue(field, value)
    }
  }

  // Funder has subfields that couldn't be affectly updated without tracking parent and child indexes
  process_funder(funders) {
    this.arrayValuesLength = funders.length

    if (this.arrayValuesLength === 0) {
      return false
    }

    funders.forEach((funder, i) => {
      // Set the parent fields container for each iteration
      var $wrapper = this.wrapper("funder", i)

      Object.entries(funder).forEach(function([childField, childValue]){
        if ($.type(childValue) === "array") {
          childValue.forEach(function(val, j) {
            // We need to get this fresh each time as we are adding DOM elements
            $($wrapper.find($(this.inputSelector(childField))).find(this.targetInputSelector).get(j)).val(val)

            if (j+1 < childValue.length) {
              this.wrapper(childField, i).find(".add-new").trigger("click")
            }
          }, this)

        } else {
          $($wrapper.find($(this.inputSelector(childField))).find(this.targetInputSelector)).val(childValue)
        }
      }, this)

      if (i+1 < this.arrayValuesLength) {
        $wrapper.find(".add_funder").trigger("click")
      } else {
        this.setUpdated("funder")
      }
    }, this)
  }

  setValue(field, value, index = 0) {
    if (this.isBlank(value)) {
      return false
    }

    let input = $($(this.inputSelector(field)).find(this.targetInputSelector).get(index))
    if (input.length > 0) {
      this.setUpdated(field)
      input.val(value)
    }
  }

  logSuccess() {
    let uniqueFields = $.unique(this.updatedFields)
    let fields = uniqueFields
      .map((field) => {
        // If we have an acronym, then use the value from the object above
        if (Object.keys(this.fieldLabelAcronyms).includes(field)) {
          return this.fieldLabelAcronyms[field]

        // Otherwise, simply Titleize it
        } else {
          return field.split("_").map((str) => { return str.charAt(0).toUpperCase() + str.slice(1) }).join(" ")
        }
      })
      .join(", ")
      .replace(/,([^,]*)$/, " and" + '$1')

    this.updatedFields = []

    let $titleMessage = $("<p/>", { text: this.successMessage })
    let $fieldsMessage = $("<p/>", { text: fields })
    let $wrapper = $("<div/>", { class: `${this.logClass} bg-success` }).append($titleMessage).append($fieldsMessage)

    $wrapper.prependTo(this.$form)
  }

  logFailure() {
    let $titleMessage = $("<p/>", { text: this.failureMessage })
    let $wrapper = $("<div/>", { class: `${this.logClass} bg-danger` }).append($titleMessage)

    $wrapper.prependTo(this.$form)
  }

  setUpdated(field) {
    this.updatedFields.push(field)
  }

  inputSelector(field) {
    return `.${this.fieldName(field)}`
  }

  // returns the jq wrapper object with the correct index
  wrapper(field, index = 0) {
    return $($(this.wrapperSelector(field)).get(index))
  }

  wrapperSelector(field) {
    return `div.${this.fieldName(field)}`
  }

  fieldName(field) {
    return `${this.response.curation_concern}_${field}`
  }

  isBlank(value) {
    value == undefined || value.length == 0
  }
}