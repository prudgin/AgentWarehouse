# Interactive skills refuse to run in auto mode

Skills that ask the user questions one at a time (`/grill`, `/triage`, parts of `/create-project`) detect auto mode at invocation and exit cleanly with a short message: "This skill requires interactive mode. Switch and re-invoke." They do not degrade to assumption-batches. Asking questions to nobody risks silent misalignment that the user only catches days later; explicit refusal is louder, safer, and forces the human into the loop at the alignment phase, where they belong.
