function [ color ] = lighten(color, factor)
  color = color + factor * (1 - color);
end
