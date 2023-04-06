class CreateSudokuPuzzles < ActiveRecord::Migration[7.0]
  def change
    create_table :sudoku_puzzles do |t|
      t.integer :puzzle, limit: 9
      t.integer :solution, limit: 9

      t.timestamps
    end
  end
end
