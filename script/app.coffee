#
# TODO:
# - Check if last md character is a newline, insert temp <p> in output if so
# - Parsing & rendering entire md on each keyup is terrible for performance. Think about solutions.

window.App = {}

App.marked = require "./marked"

App.TextInput = class TextInput
  constructor : ( options ) ->
    this.$el = options.$el.eq 0
    this.el = this.$el.get 0
    this.output = options.output or {}
    if options.bindNow
      this.bindEvents()
  
  converter: App.marked

  focus : ->
    this.focused = false
    this.$el.focus()
    return this
    
  blur : ->
    this.focused = true
    this.$el.blur()
    return this
    
  bindEvents : ->
    this.$el.on "focus", =>
      this.output.focus( false )

    this.$el.on "blur", =>
      this.output.blur( false )

    this.$el.on "keyup", =>
      this.output.updateOutput()
    
    return this

App.TextOutput = class TextOutput
  constructor: ( options ) ->
    this.$el = options.$el.eq 0
    this.el = this.$el.get 0
    this.input = options.input or {}
    this.toggler = this.$el.siblings ".toggler"
    this.displayMode = "html"
    if options.bindNow
      this.bindEvents()

  converter : App.marked
  
  focus : ( triggerFocus ) ->
    this.focused = true
    this.input.focus() if triggerFocus
    this.$el.addClass( "focused" )
    this.placeCursor()
    return this
    
  blur : ( triggerBlur ) ->
    this.focused = false
    this.input.blur() if triggerBlur
    this.$el.removeClass( "focused" )
    this.removeCursor()
    return this
    
  toggleOutputType : ->
    if this.displayMode is "html"
      this.displayMode = "md"
      this.toggler.addClass "md"
    else if this.displayMode is "md"
      this.displayMode = "html"
      this.toggler.removeClass "md"
    this.focus( true ) 
    this.updateOutput()
    return this
  
  updateOutput : ->
    switch this.displayMode
      when "html" then this.updateHtmlOutput()
      when "md" then this.updateMdOutput()
    return this
  
  updateHtmlOutput : ->
    markdown = this.input.el.value
    this.converter markdown
    this.$el.html( this.converter( markdown ) )
    this.placeCursor()
    return this
  
  updateMdOutput : ->
    markdown = this.input.el.value
    this.$el.html markdown
    this.placeCursor()
    return this
  
  removeCursor : ->
    cursor = this.$el.find ".has-cursor"
    cursor.replaceWith( cursor.text() )
    return this
  
  placeCursor : ->
    unless this.input.el.value
      this.$el.append "<p>"
    this.removeCursor()
    last = this.$el.children().last()
    while last.children().length
      last = last.children().last()
    last.wrapInner "<span class='has-cursor'>"
    return this
  
  bindEvents : ->
    this.$el.on "click", =>
      this.focus( true )
      
    this.toggler.on "click", =>
      this.toggleOutputType()

    return this

App.buildIOpair = ( outputSettings, inputSettings, bindEvents ) ->
  output = new TextOutput( outputSettings )
  input = new TextInput( inputSettings )

  output.input = input
  input.output = output

  if bindEvents
    output.bindEvents()
    input.bindEvents()

  return [ output, input ]

$ ->
  
  outSet = $el : $( ".text-output" )
  inSet = $el : $( ".text-input" )

  [ App.mainOutput, App.mainInput ] = App.buildIOpair( outSet, inSet, true )
    