`ev_features` - Extract event features
===

The `ev_features` node extracts features from an array of selected events.

## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.ev_features.new('key', value, ...);
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md


## Construction arguments

The `ev_features` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For configuration options specific to this
node class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the [node API documentation][node].

[node]: ../


