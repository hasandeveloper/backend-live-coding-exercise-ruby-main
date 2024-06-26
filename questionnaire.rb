require "pstore" # https://github.com/ruby/pstore

STORE_NAME = "tendable.pstore"
store = PStore.new(STORE_NAME)

QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

# Function to prompt the user with questions and collect answers
def do_prompt
  answers = QUESTIONS.map do |question_key, question|
    print "#{question} (Yes/No): "
    answer = gets.chomp.strip.downcase
    until %w[yes no y n].include?(answer)
      puts "Invalid answer. Please respond with Yes, No, Y, or N."
      print "#{question} (Yes/No): "
      answer = gets.chomp.strip.downcase
    end
    [question_key, answer.start_with?('y') ? 'yes' : 'no']
  end.to_h
  save_answers(answers)
  answers
end

# Function to save answers to the PStore
def save_answers(answers)
  store = PStore.new(STORE_NAME)
  store.transaction do
    store[:runs] ||= []
    store[:runs] << answers
  end
end

# Function to calculate the rating based on answers
def calculate_rating(answers)
  yes_count = answers.values.count('yes')
  total_questions = answers.size
  (100.0 * yes_count / total_questions).round(2)
end

# Function to calculate the overall average rating across all runs
def calculate_overall_rating
  store = PStore.new(STORE_NAME)
  store.transaction do
    all_runs = store[:runs] || []
    return 0 if all_runs.empty?

    total_yes = all_runs.sum { |run| run.values.count('yes') }
    total_questions = all_runs.size * QUESTIONS.size
    (100.0 * total_yes / total_questions).round(2)
  end
end

# Function to print the report with the current and overall ratings
def do_report(answers)
  current_rating = calculate_rating(answers)
  overall_rating = calculate_overall_rating

  puts "Your rating for this run is: #{current_rating}%"
  puts "The average rating for all runs is: #{overall_rating}%"
end

# Main flow
answers = do_prompt
do_report(answers)
