from graphviz import Source
path = './view_file_synth.dot'
s = Source.from_file(path)
s.view()