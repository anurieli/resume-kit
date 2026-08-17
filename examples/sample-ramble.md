> **Example file.** This is what a captured ramble looks like after
> `career-enrich` saves it: the person talked for a few minutes, the skill
> got out of the way, and the account was written down in their own words
> with light cleanup only. In a real workspace this file would live at
> `02_career-db/self/reflections/northwind-billing-migration.md` and be
> referenced from `exp-northwind-2021` in `career.yaml`. The person is
> fictional (Jordan Rivera, same as `career.example.yaml`).
>
> Notice what is in here that no resume would hold: why the project existed,
> who did not want it, what the hard part actually was, and an opinion the
> person holds about themselves. Notice also that the numbers are vague. The
> hard numbers for this role came from a performance review during
> ingestion, not from this conversation, which is exactly the split the
> `evidence_type` field exists to keep straight.

# Northwind billing migration

**Captured:** 2026-08-15
**Prompted by:** "What was the hardest part of the billing migration, and
was it the technical part?"

---

Honestly, no. The technical part was the easy part.

So the setup was, billing reconciliation ran as this nightly batch job that
somebody wrote in 2016 and then left. It pulled from four systems, did a
bunch of joins, and spat out a report that finance used to close the books.
And it was wrong. Not wildly wrong, but wrong often enough that finance had
built their own spreadsheet to check it, which meant we had two sources of
truth and neither of them was trusted.

Everyone knew it was broken. Nobody wanted to touch it, because the moment
you touch billing you own billing. That is the actual reason it sat there
for five years. It was not a hard problem, it was an unattractive one.

I ended up picking it up because I was debugging something adjacent and kept
hitting it, and at some point it was easier to just fix the thing than to
keep working around it. Nobody assigned it to me. I want to be clear about
that because it came up in my review later and my manager framed it as me
taking initiative, but at the time it genuinely just felt like the path of
least resistance.

The rewrite itself was event driven, we put it on Kafka, standard stuff. Six
hours down to about twenty minutes, and the error rate dropped a lot, I
think it was around forty percent fewer discrepancies but you would have to
check the review for the real number. I do not trust my memory on that.

Here is the part that actually took the time. Finance and engineering did
not agree on what a reconciliation error was. Engineering counted a row that
failed to match. Finance counted a dollar amount that came out wrong at the
end of the month. Those are completely different numbers and both teams had
been reporting theirs for years, in the same meetings, as if they were the
same metric. So the first six weeks of a four month project was me sitting
with two people from finance going line by line through what they meant.

I built nothing for six weeks. If you had looked at my commits you would
have thought I had stopped working.

But that is the reason it worked. When we shipped, finance already agreed
with the definition, so when the new numbers came out different from the old
spreadsheet, nobody panicked, because we had already agreed the old
spreadsheet was measuring something else. I have seen migrations like that
land and get rolled back inside a week because nobody did that part.

That is the thing I would say I am actually good at, if I had to pick one.
Not the Kafka part. Lots of people can do the Kafka part. Getting two groups
who think they are talking about the same number to find out that they are
not, before you build anything. That is the bit I keep ending up doing.

Team was four of us by the end, though it was just me for the first couple
of months. I owned it end to end for about eight months including the
rollout.

One more thing. After we shipped, I rewrote the on-call runbook for it,
because the old one was three failure modes out of date and we kept paging
people for things that had a known fix. That cut the repeat pages down to
basically nothing. That never went in any review and I would not have
thought to put it on a resume, it just seemed like cleanup.

I should probably say the downside too. The reason this keeps landing on me
is that I am bad at saying no to it. Something is broken, nobody owns it, I
notice, and then it is mine. That has worked out career wise so far. I am
not sure it will keep working out.
