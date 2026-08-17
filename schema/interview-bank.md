# Interview bank

The questions `career-enrich` draws from. Not a script to read top to bottom.
Pick what the record is actually missing, ask a few, shut up and listen.

## How to use this

1. Read `career.yaml` and find the thinnest thing. A role with no metrics, a
   recent job with no reflections, an empty `self_assessment`.
2. Ask **three to five questions per session**, not twenty. This is a
   conversation, not a form. People give better answers in the first ten
   minutes than the next forty.
3. Follow the thread. If an answer opens something up, chase it instead of
   moving to the next scripted question.
4. Never ask something the record already answers. Asking "what did you do
   at Acme" when three bullets are already logged tells the person you did
   not read their file.
5. Write what you get, mark it `self-reported` (facts and events) or
   `self-assessment` (opinions about themselves), and update
   `meta.enrichment_gaps` with what is still thin.

## Getting the real story out of a job

- "What did you actually do there that never made it onto the resume?"
- "What was broken when you got there?"
- "What did you start that nobody asked you to start?"
- "What would have gone wrong if you had not been there?"
- "Who was annoyed by your work, and were they right?"
- "What was the hardest part, and was it the technical part?"

That last one is the highest-yield question in this file. The answer is
almost never the technical part, and the real answer is usually the thing
that makes someone senior.

## Getting numbers

People systematically under-quantify their own work. Push once, gently.

- "Can you put a number on that? Even a rough one."
- "How long was it taking before? How long after?"
- "How many people did that affect?"
- "What was it costing before you fixed it?"

If they genuinely do not know, log it without a metric. A vague number
invented to sound good is worse than no number. Check performance reviews in
intake first: they usually contain numbers the person has forgotten.

## Soft skills and self-assessment

These never appear in a document you can parse, so they only come from
asking. Everything here is `self-assessment` unless it is a specific event.

- "What do people come to you for that isn't in your job description?"
- "What do you get asked to do again and again, across different jobs?"
- "What's the compliment you get that you don't quite believe?"
- "What were you bad at three years ago that you are good at now?"
- "What are you genuinely not good at?"
- "Where do you do your best work? What kind of team, what kind of pressure?"

The "not good at" question matters as much as the strengths. A record that
only lists strengths cannot warn someone off a bad-fit role, and the honest
gap list is what makes the coaching useful later.

## Growth and direction

- "What kind of work do you want more of?"
- "What would you not do again?"
- "If the title didn't matter, what would you be doing?"

Store these under `self_assessment.prefers` and `working_on`. They shape
which roles are worth targeting, not just how a resume reads.

## Capturing a ramble

When someone talks freely rather than answering a question, do not interrupt
to structure it. Let them finish, then:

1. Write the raw account to
   `02_career-db/self/reflections/<slug>.md`, lightly cleaned up but in their
   words. Their phrasing is often better than yours and worth keeping.
2. Extract into `career.yaml`: any concrete events as achievements or
   `context` (`self-reported`), any opinions about themselves into
   `self_assessment`.
3. Link the reflection from the relevant experience's `reflections:` list.
4. Read back only what you extracted as fact, and ask if you got it right.
   Do not read back the whole thing.

## What not to do

- Do not interview on the first run before ingestion. Read their documents
  first so you can ask informed questions rather than generic ones.
- Do not ask twenty questions in a row. Three to five, then write.
- Do not fill silence by suggesting answers. "Would you say you're good at
  leadership?" gets you a yes and teaches you nothing.
- Do not upgrade what you hear. "I helped with the migration" is not "led
  the migration."
