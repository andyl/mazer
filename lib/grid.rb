require 'chunky_png'
require_relative 'cell'

##
# Grid class
class Grid
  attr_reader :rows, :cols

  def initialize(rows, cols)
    @rows = rows
    @cols = cols
    @grid = prepare_grid
    configure_cells
  end

  def prepare_grid
    Array.new(rows) do |row|
      Array.new(cols) do |col|
        Cell.new(row, col)
      end
    end
  end

  def configure_cells
    each_cell do |cell|
      row, col = cell.row, cell.col
      cell.north = self[row - 1, col]
      cell.south = self[row + 1, col]
      cell.west = self[row, col - 1]
      cell.east = self[row, col + 1]
    end
  end

  def [](row, col)
    return nil unless row.between?(0, @rows - 1)
    return nil unless col.between?(0, @grid[row].count - 1)

    @grid[row][col]
  end

  def random_cell
    row = rand(@rows)
    column = rand(@grid[row].count)
    self[row, column]
  end

  def size
    @rows * @columns
  end

  def each_row(&block)
    @grid.each(&block)
  end

  def each_cell
    each_row do |row|
      row.each do |cell|
        yield cell if cell
      end
    end
  end

  def contents_of(_cell)
    " "
  end

  def to_s
    multic = "---+" * cols
    output = "+#{multic}\n"
    each_row do |row|
      top = "|"
      bottom = "+"
      row.each do |cell|
        cell ||= Cell.new(-1, -1)
        body = " #{contents_of(cell)} "
        east_boundary = (cell.linked?(cell.east) ? " " : "|")
        top << body << east_boundary
        south_boundary = (if cell.linked?(cell.south)
                            "   "
                          else
                            "---"
                          end)
        corner = "+"
        bottom << south_boundary << corner
      end
      output << top << "\n"
      output << bottom << "\n"
    end
    output
  end

  def to_png(cell_size: 10)
    img_width = cell_size * cols
    img_height = cell_size * rows
    background = ChunkyPNG::Color::WHITE
    wall = ChunkyPNG::Color::BLACK
    img = ChunkyPNG::Image.new(img_width + 1, img_height + 1, background)
    each_cell do |cell|
      x1 = cell.col * cell_size
      y1 = cell.row * cell_size
      x2 = (cell.col + 1) * cell_size
      y2 = (cell.row + 1) * cell_size
      img.line(x1, y1, x2, y1, wall) unless cell.north
      img.line(x1, y1, x1, y2, wall) unless cell.west
      img.line(x2, y1, x2, y2, wall) unless cell.linked?(cell.east)
      img.line(x1, y2, x2, y2, wall) unless cell.linked?(cell.south)
    end
    img
  end

end
