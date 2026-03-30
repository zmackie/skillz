# The Revenge of the Data Scientist – Hamel’s Blog - Hamel Husain

**Source:** https://hamel.dev/blog/posts/revenge/#fn3
**Saved:** 2026-03-28T19:39:29.070Z

*Generated with [markdown-printer](https://github.com/levz0r/markdown-printer) (v1.1.1) by [Lev Gelfenbuim](https://lev.engineer)*

---

# The Revenge of the Data Scientist

[LLMs](/index.html#category=LLMs)

[evals](/index.html#category=evals)

Is Data Science in decline?

Author

Hamel Husain

Published

March 26, 2026

---

Is the heyday of the data scientist over? The Harvard Business Review once called it “The Sexiest Job of the 21st Century.”[1](https://hamel.dev/blog/posts/revenge/#fn1) In tech, data scientist roles were often among the best paid.[2](https://hamel.dev/blog/posts/revenge/#fn2) The job also demanded an unusual mix of skills:

---

In addition to creating a high-barrier to entry, these skills enabled data scientists to build predicitive models, measure casuality and find patterns in data. Of these, predicitive modeling paid best. Companies later peeled that work off into a new title: Machine Learning Engineer (“MLE”).[3](https://hamel.dev/blog/posts/revenge/#fn3)

---

For years, shipping AI meant keeping data scientists and MLEs on the critical path. With LLMs, this stopped being the default. Foundation-model APIs now allow teams to integrate AI independently.

---

## The Harness Is Data Science[](#the-harness-is-data-science)

![](images/slide_2.png)

OpenAI published a blog post on [harness engineering](https://openai.com/index/harness-engineering/) that I recommend reading. They describe how Codex worked on a software project for months, autonomously, with agents developing code bounded by a harness of tests and specifications.

![](images/slide_3.png)

One detail in that blog post is easy to miss. The harness includes an observability stack: logs, metrics, and traces exposed to the agent so it can tell when it is going off track. In addition to tests and specifications, there are metrics. That is a key component of the system.

![](images/slide_4.png)

Andrej Karpathy’s [auto-research project](https://x.com/karpathy/status/1936185694238064845) shows the same pattern: models iteratively optimize against a validation loss metric. Same idea, different harness.

![](images/slide_5.png)

What I want to convince you of is that a large portion of the harness is data science.

Let’s take a step back and take stock of where we are.

![](images/slide_6.png)

Years ago, practitioners spent hours examining data, checking label alignment, and designing metrics. Today, we build on “vibes,” ask the model if it did a good job, and grab off-the-shelf metric libraries without looking at the data.

![](images/slide_7.png)

This shows up most around retrieval and evals. Without a data background, engineers fear what they don’t understand. They claim “RAG is dead” or “evals are dead,” yet build systems that depend on those concepts.

The rest of this post walks through five eval pitfalls I see repeatedly, and what a data scientist would do differently in each case.

* * *

---

## Generic Metrics[](#generic-metrics)

The first pitfall is generic metrics.

![](images/slide_9.png)

It is tempting to reach for an eval framework and use its metrics off the shelf. The problem: you have no idea what is actually broken. Most teams put up a dashboard with helpfulness scores, coherence scores, hallucination scores. These sound reasonable. They are also generic enough to be useless for diagnosing your application’s failures.

A data scientist would not adopt metrics off the shelf. They would explore the data, explore the traces, ask “what is actually breaking here?”, and figure out the highest-value thing to start measuring. There are infinite things to measure. You have to form hypotheses and iterate.

The best medicine for this pitfall is looking at the data.

![](images/slide_12.png)

What does “looking at the data” mean in practice? It means reading traces. Code your own custom trace viewer so you can remove friction and customize the display for your domain’s quirks. Take notes on problems you find. Do error analysis: categorize failures, figure out what to prioritize, decide what to work on.

![](images/slide_13.png)

When you look at your data, you end up driving toward application-specific metrics. Off-the-shelf similarity metrics like ROUGE or BLEU rarely fit LLM outputs. The metrics that matter look like “Calendar Scheduling Failure” or “Failure to Escalate To Human.”

![](images/slide_14.png)

If there is one thing to take away from this post: look at the data. How to look at it is a separate question and takes practice. This is the higest ROI activity you can engage in and is often skipped.

* * *

---

## Unverified Judges[](#unverified-judges)

The second pitfall is unverified judges. A lot of teams use an LLM as a judge to figure out whether their AI is working. Most of the time, nobody has a good answer to “how do you trust the judge?”

![](images/slide_15.png)

The default: ask an LLM to rate outputs on a scale and use the numbers. A data scientist would treat the judge like a classifier. You have a black box giving you a prediction. How do you trust it? Get human labels, partition the data into train/dev/test, and measure whether the classifier is trustworthy.

![](images/slide_18.png)

Source few-shot examples from your training set. Hill-climb your judge’s prompt against a dev set. Keep a test set aside to confirm you haven’t overfit. If you have done machine learning before, this is boring. But people are not doing it. Verifying classifiers has become a lost art in modern AI.

![](images/slide_19.png)

Treat your judge like a classifier in how you report results, too. Everywhere I go I see accuracy reported. If a failure mode occurs 5% of the time, accuracy hides the system’s true performance. Use precision and recall.

* * *

---

## Bad Experimental Design[](#bad-experimental-design)

The third pitfall is experimental design. There are many dimensions to this. Here are two that come up most.

![](images/slide_20.png)

The first is constructing test sets. Most teams generate synthetic data by prompting an LLM: “Give me 50 test queries.” They get generic, unrepresentative data. A data scientist would look at real production data first, use hypotheses to determine which dimensions matter, then generate synthetic examples along those dimensions.

![](images/slide_23.png)

Ground synthetic data in real logs or traces. Figure out what dimensions to vary. Inject edge cases. Base the synthetic data off real data.

![](images/slide_26.png)

The second is metric design. Teams bundle entire rubrics into a single LLM call and default to 1-5 Likert scales. A data scientist would reduce complexity, make each metric actionable, and tie it to a business outcome. Replace subjective scales with binary pass/fail on scoped criteria. Likert scales hide ambiguity and kick the can down the road on hard decisions about system performance.

* * *

---

## Bad Data and Labels[](#bad-data-and-labels)

The fourth pitfall is bad data and labels. Data scientists don’t trust the data. They don’t trust the labels. They don’t trust anything. They are skeptical by training. AI engineers at large have not built this muscle yet.

![](images/slide_27.png)

When it comes to labeling, most teams make it someone else’s problem. Labeling seems unglamorous, so it gets delegated to the dev team or outsourced. A data scientist would insist that domain experts label the data, stay skeptical of the labels, and look at the data.

![](images/slide_30.png)

But labeling matters for a deeper reason than label quality. It is impossible to know what you want unless you look at the data. There is a concept called “criteria drift,” validated in a [paper by Shreya Shankar and colleagues](https://arxiv.org/abs/2404.12272): users need criteria to grade outputs, but grading outputs helps users define their criteria. People don’t know what they want until they see the LLM’s outputs. The labeling process itself surfaces what matters.

![](images/slide_31.png)

Data scientists champion this: get domain experts and product managers in front of raw data, not summary scores.

* * *

---

## Automating Too Much[](#automating-too-much)

The fifth pitfall is automating too much. All of this is human work. The temptation is to automate it away.

![](images/slide_32.png)

![](images/slide_33.png)

LLMs can help wire things up, write the plumbing, generate boilerplate for evaluations. They cannot look at the data for you, for the exact reason we just discussed: you don’t know what you want until you see the outputs.

* * *

---

## Other Pitfalls[](#other-pitfalls)

We did not have time to cover every pitfall. Here is a speed run through the rest.

![](images/slide_34.png)

Misusing similarity scores. Asking the judge vague questions like “is it helpful?” Making annotators read raw JSON. Reporting uncalibrated scores without confidence intervals. Data drift, overfitting, not sampling correctly, dashboards that don’t make sense.

* * *

---

## The Mapping[](#the-mapping)

If you zoom out, every pitfall above has the same root cause: missing a data science fundamental.

![](images/slide_35.png)

Reading traces and categorizing failures is Exploratory Data Analysis. Validating an LLM judge against human labels is Model Evaluation. Building representative test sets from production data is Experimental Design. Getting domain experts to label outputs is Data Collection. Monitoring whether your product works in production is Production ML. None of this is new. The names changed, the work did not.

![](images/slide_36.png)

This is a Python conference, so: Python remains the best toolset for looking at your data and dealing with data.

![](images/slide_37.png)

I built an [open-source plugin](https://github.com/hamelsmu/evals-skills) that goes into more depth. Point it at your eval pipeline and it will tell you what you are doing wrong, or try its best to.

![](images/slide_38.png)

Always look at the data.

If you enjoyed the memes in this talk, there are [many more on my website](https://hamel.dev/notes/llm/evals/memes/#meme-images).

If you want to go deeper on any of these topics, the [slides](https://hamel.dev/blog/posts/revenge/#slides) and [video](https://hamel.dev/blog/posts/revenge/#video) are below.

_Thanks to [Shreya Shankar](https://www.sh-reya.com/) and [Bryan Bischof](https://x.com/BEBischof) for many conversations that shaped this talk._

* * *

---

Is the heyday of the data scientist over? The Harvard Business Review once called it “The Sexiest Job of the 21st Century.”[1](https://hamel.dev/blog/posts/revenge/#fn1) In tech, data scientist roles were often among the best paid.[2](https://hamel.dev/blog/posts/revenge/#fn2) The job also demanded an unusual mix of skills:

In addition to creating a high-barrier to entry, these skills enabled data scientists to build predicitive models, measure casuality and find patterns in data. Of these, predicitive modeling paid best. Companies later peeled that work off into a new title: Machine Learning Engineer (“MLE”).[3](https://hamel.dev/blog/posts/revenge/#fn3)

For years, shipping AI meant keeping data scientists and MLEs on the critical path. With LLMs, this stopped being the default. Foundation-model APIs now allow teams to integrate AI independently.

Getting cut out of the loop rattled data scientists and MLEs I know. If the company no longer needs you to ship AI, it is fair to wonder whether the job still has the same upside. The harsher story people tell themselves: unless you are pretraining at a foundation-model lab, you are not where the action is.

I read it the other way. Training models was never most of the job. The bulk of the work is setting up experiments to test how well the AI generalizes to unseen data, debugging stochastic systems, and designing good metrics. Calling an LLM over an API does not make this work go away.

I recently gave a talk titled “The Revenge of the Data Scientist” at [PyAI Conf](https://pyai.events/) to make that case with examples rather than assertion alone. Below is an annotated version of that presentation.

![](images/slide_1.png)

## The Harness Is Data Science[](#the-harness-is-data-science)

![](images/slide_2.png)

OpenAI published a blog post on [harness engineering](https://openai.com/index/harness-engineering/) that I recommend reading. They describe how Codex worked on a software project for months, autonomously, with agents developing code bounded by a harness of tests and specifications.

![](images/slide_3.png)

One detail in that blog post is easy to miss. The harness includes an observability stack: logs, metrics, and traces exposed to the agent so it can tell when it is going off track. In addition to tests and specifications, there are metrics. That is a key component of the system.

![](images/slide_4.png)

Andrej Karpathy’s [auto-research project](https://x.com/karpathy/status/1936185694238064845) shows the same pattern: models iteratively optimize against a validation loss metric. Same idea, different harness.

![](images/slide_5.png)

What I want to convince you of is that a large portion of the harness is data science.

Let’s take a step back and take stock of where we are.

![](images/slide_6.png)

Years ago, practitioners spent hours examining data, checking label alignment, and designing metrics. Today, we build on “vibes,” ask the model if it did a good job, and grab off-the-shelf metric libraries without looking at the data.

![](images/slide_7.png)

This shows up most around retrieval and evals. Without a data background, engineers fear what they don’t understand. They claim “RAG is dead” or “evals are dead,” yet build systems that depend on those concepts.

The rest of this post walks through five eval pitfalls I see repeatedly, and what a data scientist would do differently in each case.

* * *

## Generic Metrics[](#generic-metrics)

The first pitfall is generic metrics.

![](images/slide_9.png)

It is tempting to reach for an eval framework and use its metrics off the shelf. The problem: you have no idea what is actually broken. Most teams put up a dashboard with helpfulness scores, coherence scores, hallucination scores. These sound reasonable. They are also generic enough to be useless for diagnosing your application’s failures.

A data scientist would not adopt metrics off the shelf. They would explore the data, explore the traces, ask “what is actually breaking here?”, and figure out the highest-value thing to start measuring. There are infinite things to measure. You have to form hypotheses and iterate.

The best medicine for this pitfall is looking at the data.

![](images/slide_12.png)

What does “looking at the data” mean in practice? It means reading traces. Code your own custom trace viewer so you can remove friction and customize the display for your domain’s quirks. Take notes on problems you find. Do error analysis: categorize failures, figure out what to prioritize, decide what to work on.

![](images/slide_13.png)

When you look at your data, you end up driving toward application-specific metrics. Off-the-shelf similarity metrics like ROUGE or BLEU rarely fit LLM outputs. The metrics that matter look like “Calendar Scheduling Failure” or “Failure to Escalate To Human.”

![](images/slide_14.png)

If there is one thing to take away from this post: look at the data. How to look at it is a separate question and takes practice. This is the higest ROI activity you can engage in and is often skipped.

* * *

## Unverified Judges[](#unverified-judges)

The second pitfall is unverified judges. A lot of teams use an LLM as a judge to figure out whether their AI is working. Most of the time, nobody has a good answer to “how do you trust the judge?”

![](images/slide_15.png)

The default: ask an LLM to rate outputs on a scale and use the numbers. A data scientist would treat the judge like a classifier. You have a black box giving you a prediction. How do you trust it? Get human labels, partition the data into train/dev/test, and measure whether the classifier is trustworthy.

![](images/slide_18.png)

Source few-shot examples from your training set. Hill-climb your judge’s prompt against a dev set. Keep a test set aside to confirm you haven’t overfit. If you have done machine learning before, this is boring. But people are not doing it. Verifying classifiers has become a lost art in modern AI.

![](images/slide_19.png)

Treat your judge like a classifier in how you report results, too. Everywhere I go I see accuracy reported. If a failure mode occurs 5% of the time, accuracy hides the system’s true performance. Use precision and recall.

* * *

## Bad Experimental Design[](#bad-experimental-design)

The third pitfall is experimental design. There are many dimensions to this. Here are two that come up most.

![](images/slide_20.png)

The first is constructing test sets. Most teams generate synthetic data by prompting an LLM: “Give me 50 test queries.” They get generic, unrepresentative data. A data scientist would look at real production data first, use hypotheses to determine which dimensions matter, then generate synthetic examples along those dimensions.

![](images/slide_23.png)

Ground synthetic data in real logs or traces. Figure out what dimensions to vary. Inject edge cases. Base the synthetic data off real data.

![](images/slide_26.png)

The second is metric design. Teams bundle entire rubrics into a single LLM call and default to 1-5 Likert scales. A data scientist would reduce complexity, make each metric actionable, and tie it to a business outcome. Replace subjective scales with binary pass/fail on scoped criteria. Likert scales hide ambiguity and kick the can down the road on hard decisions about system performance.

* * *

## Bad Data and Labels[](#bad-data-and-labels)

The fourth pitfall is bad data and labels. Data scientists don’t trust the data. They don’t trust the labels. They don’t trust anything. They are skeptical by training. AI engineers at large have not built this muscle yet.

![](images/slide_27.png)

When it comes to labeling, most teams make it someone else’s problem. Labeling seems unglamorous, so it gets delegated to the dev team or outsourced. A data scientist would insist that domain experts label the data, stay skeptical of the labels, and look at the data.

![](images/slide_30.png)

But labeling matters for a deeper reason than label quality. It is impossible to know what you want unless you look at the data. There is a concept called “criteria drift,” validated in a [paper by Shreya Shankar and colleagues](https://arxiv.org/abs/2404.12272): users need criteria to grade outputs, but grading outputs helps users define their criteria. People don’t know what they want until they see the LLM’s outputs. The labeling process itself surfaces what matters.

![](images/slide_31.png)

Data scientists champion this: get domain experts and product managers in front of raw data, not summary scores.

* * *

## Automating Too Much[](#automating-too-much)

The fifth pitfall is automating too much. All of this is human work. The temptation is to automate it away.

![](images/slide_32.png)

![](images/slide_33.png)

LLMs can help wire things up, write the plumbing, generate boilerplate for evaluations. They cannot look at the data for you, for the exact reason we just discussed: you don’t know what you want until you see the outputs.

* * *

## Other Pitfalls[](#other-pitfalls)

We did not have time to cover every pitfall. Here is a speed run through the rest.

![](images/slide_34.png)

Misusing similarity scores. Asking the judge vague questions like “is it helpful?” Making annotators read raw JSON. Reporting uncalibrated scores without confidence intervals. Data drift, overfitting, not sampling correctly, dashboards that don’t make sense.

* * *

## The Mapping[](#the-mapping)

If you zoom out, every pitfall above has the same root cause: missing a data science fundamental.

![](images/slide_35.png)

Reading traces and categorizing failures is Exploratory Data Analysis. Validating an LLM judge against human labels is Model Evaluation. Building representative test sets from production data is Experimental Design. Getting domain experts to label outputs is Data Collection. Monitoring whether your product works in production is Production ML. None of this is new. The names changed, the work did not.

![](images/slide_36.png)

This is a Python conference, so: Python remains the best toolset for looking at your data and dealing with data.

![](images/slide_37.png)

I built an [open-source plugin](https://github.com/hamelsmu/evals-skills) that goes into more depth. Point it at your eval pipeline and it will tell you what you are doing wrong, or try its best to.

![](images/slide_38.png)

Always look at the data.

If you enjoyed the memes in this talk, there are [many more on my website](https://hamel.dev/notes/llm/evals/memes/#meme-images).

If you want to go deeper on any of these topics, the [slides](https://hamel.dev/blog/posts/revenge/#slides) and [video](https://hamel.dev/blog/posts/revenge/#video) are below.

_Thanks to [Shreya Shankar](https://www.sh-reya.com/) and [Bryan Bischof](https://x.com/BEBischof) for many conversations that shaped this talk._

* * *

## Video & Slides[](#video-slides)

[Link to the slides](https://docs.google.com/presentation/d/1Q7F7cr5PthTmsl6RQCofyBBlH23fh4FlaO_5tbWxbTs/edit?usp=sharing)

* * *

## Footnotes[](#footnotes-1)

1.  https://hbr.org/2012/10/data-scientist-the-sexiest-job-of-the-21st-century[↩︎](https://hamel.dev/blog/posts/revenge/#fnref1)
    
2.  https://www.forbes.com/sites/louiscolumbus/2018/01/29/data-scientist-is-the-best-job-in-america-according-glassdoors-2018-rankings/[↩︎](https://hamel.dev/blog/posts/revenge/#fnref2)
    
3.  https://www.mckinsey.com/about-us/new-at-mckinsey-blog/ai-reinvents-tech-talent-opportunities[↩︎](https://hamel.dev/blog/posts/revenge/#fnref3)

---

Getting cut out of the loop rattled data scientists and MLEs I know. If the company no longer needs you to ship AI, it is fair to wonder whether the job still has the same upside. The harsher story people tell themselves: unless you are pretraining at a foundation-model lab, you are not where the action is.

---

I read it the other way. Training models was never most of the job. The bulk of the work is setting up experiments to test how well the AI generalizes to unseen data, debugging stochastic systems, and designing good metrics. Calling an LLM over an API does not make this work go away.

---

I recently gave a talk titled “The Revenge of the Data Scientist” at [PyAI Conf](https://pyai.events/) to make that case with examples rather than assertion alone. Below is an annotated version of that presentation.