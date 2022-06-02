from graphviz import Source
path = './view_file.dot'
s = Source.from_file(path)
s.view()