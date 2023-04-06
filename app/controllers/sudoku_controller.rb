class SudokuController < ApplicationController

  MAX_RECURSION_DEPTH = 1000

  def solve
    puts "params: #{params.inspect}"
    puzzle = params[:puzzle]
    if puzzle.present?
      solution = solve_sudoku(puzzle)
      if solution.present?
        sudoku_puzzle = SudokuPuzzle.new(puzzle: puzzle.to_json)
        sudoku_puzzle.solution = solution.to_json
        sudoku_puzzle.save
        render json: { solved_puzzle: solution }, status: :created
      else
        render json: { error: "Unable to solve puzzle" }, status: :unprocessable_entity
      end
    else
      render json: { error: "Missing parameter 'puzzle'" }, status: :bad_request
    end
  end

  private

  def solve_sudoku(puzzle)
    stack = []
    memo = {}
    stack.push(puzzle)

    while !stack.empty?
      puzzle = stack.pop
      row,col = find_empty_cell(puzzle)
      if row.nil?
        return puzzle
      end
      memo_key = puzzle.flatten.to_s
      if memo[memo_key]
        next
      end
      memo[memo_key] = true
      (1..9).each do |value|
        if valid_move?(puzzle, row, col, value)
          new_puzzle = Marshal.load(Marshal.dump(puzzle))
          new_puzzle[row][col] = value
          stack.push(new_puzzle)
        end
      end
    end
    nil
  end

  def find_empty_cell(puzzle)
    puzzle.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        return [i, j] if cell == 0
      end
    end
    [nil, nil]
  end

  def valid_move?(puzzle, row, col, value)
    return false if puzzle[row].include?(value)

    return false if puzzle.any? { |r| r[col] == value }

    box_row = (row / 3) * 3
    box_col = (col / 3) * 3
    box_cells = puzzle[box_row..box_row+2].map { |r| r[box_col..box_col+2] }.flatten
    return false if box_cells.include?(value)
    true
  end
end
