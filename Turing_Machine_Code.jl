mutable struct turingMachine
    #=
        A mutable struct to hold variables that uniquely define the instantaneous desctiption of any single-tape Turing machine at any time
    =#

    # What the machine is called
    machineName :: String
    # The string of symbols on the worktape of the Turing machine, also where the initial input it given
    tape :: String
    # The index of the character in the tape string that the Turing machine's head (what is uses to read/write the tape) is over/can act on
    headLocation :: UInt8
    # The label of the internal state of the Turing machine
    machineState :: UInt8
    # The transition table defining the transition table - and hence the dynamics - of the Turing machine
    transitionTable :: Dict{Tuple{Char, UInt8}, Tuple{Char, UInt8, UInt8}}
    # Sets containing the accepting and rejecting states, respectively. I.e. the states where the machine halts
    acceptingStates :: Set{UInt8}
    rejectingStates :: Set{UInt8}
end

function initialize_machine(name::String, input::String, instructions::Dict{Tuple{Char, UInt8}, Tuple{Char, UInt8, UInt8}}, accepting::Set{UInt8},
    rejecting::Set{UInt8})
    #=
        A simple function to initilize a turingMachine object with a valid initial setup

        INPUTS
            name         : The name to be given to the created Turing machine                       : String
            input        : The string of symbols that are initially on the Turing machine's tape    : String
            instructions : The transition table defining the Turing machine                         : Dict{Tuple{Char, UInt8}, Tuple{Char, UInt8, UInt8}}
            accepting    : The states of the Turing machine that indicate it should halt and accept : Set{UInt8}
            rejecting    : The states of the Turing machine that indicate it should halt and reject : Set{UInt8}

        OUTPUT
            A turingMachine object with the specified properties, in a valid initial setup
    =#
    return turingMachine(name, input, convert(Int8, 1), convert(Int8, 0), instructions, accepting, rejecting) # Head location is at 1 as Julia doesn't zero index
end

function singleStep(turingMachine)
    #=
        Applies the effect of a single time step to a specified Turing machine

        INPUT
            turingMachine : the Turing machine to evolve for a single time step : turingMachine object

        OUTPUT
            none

        SIDE EFFECT
            The specified Turing machine is updated - in place - according to the effects of a single time step
    =#

    # Finds the changes to make to the Turing machine based on the current state
    char_under_head::Char = turingMachine.tape[turingMachine.headLocation]
    changes_to_make::Tuple{Char, UInt8, UInt8} = getindex(turingMachine.transitionTable, (char_under_head, turingMachine.machineState))

    # Constructs the updated string of the tape
    new_tape::Vector{Char} = collect.(turingMachine.tape)
    new_tape[turingMachine.headLocation] = changes_to_make[1]
    # Update to make sure the string is long enough here.???

    # Updates the Turing machine
    turingMachine.tape = join(new_tape)
    turingMachine.headLocation += changes_to_make[2] # Need to check this doesn't go off the edge
    turingMachine.machineState = changes_to_make[3]

end

function simulationMachine(turingMachine)
    #=
        Simulates the specified Turing machine until it halts, if it ever does.

        INPUT:
            turingMachine : Specifies the Turing machine to simulate : turingMachine object

        OUTPUT:
            If the specified Turing machine accepts, given it halts : Bool

        WARNING: This function may loop infinitely
    =#

    # Loops endlessly to allow the Turing machine to function until it returns a decision (which it will not always do)
    while true

        # If the machine is in a halting state, return the corresponding output
        if turingMachine.machineState in turingMachine.acceptingStates
            return true
        elseif turingMachine.machineState in turingMachine.rejectingStates
            return false
        # If the machine is not in a halting state, make a single step
        else
            singleStep(turingMachine)
        end
    end
end

### TESTING ###


# Value to test
testInput::String = "11000110111" # CHANGE THIS HOWEVER YOU LIKE


testName::String = "Bob"
setAccepting::Set{UInt8} = Set(convert(Int8, 4))
setRejecting::Set{UInt8} = Set(convert(Int8, 3))

# Only use one of the below transition tables at a time: it is what specifies what the Turing Machine does. Also need to change the accpeting and rejecting states

# Decides if the first bit of a binary string is '1'
#transitionTable::Dict{Tuple{Char, UInt8}, Tuple{Char, UInt8, UInt8}}  = Dict(('0', 0 ) => ('0', 0, 1), ('1', 0 ) => ('1', 0, 2))

# Decides if the third bit of a binary string is '1'
transitionTable::Dict{Tuple{Char, UInt8}, Tuple{Char, UInt8, UInt8}}  = Dict(('0', 0 ) => ('0', 1, 1), ('1', 0 ) => ('1', 1, 1), ('0', 1 ) => ('0', 1, 2), ('1', 1 ) => ('1', 1, 2), ('0', 2 ) => ('0', 0, 3), ('1', 2 ) => ('1', 0, 4)) 

testingMachine = initialize_machine(testName, testInput, transitionTable, setAccepting, setRejecting)
testOutput::Bool = simulationMachine(testingMachine)
