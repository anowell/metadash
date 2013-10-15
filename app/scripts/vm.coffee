MetaDash.VM.views = {};

# Some semblence of a view manager
MetaDash.VM.create = (context, name, View, options) ->
  views = MetaDash.VM.views
  if views[name]?
    views[name].undelegateEvents()
    views[name].clean() if typeof views[name].clean == 'function'
  
  throw("Error with View: " + name) unless View?
  
  view = new View(options)
  views[name] = view
  
  context.children = {} unless context.children?
  context.children[name] = view;

  view;