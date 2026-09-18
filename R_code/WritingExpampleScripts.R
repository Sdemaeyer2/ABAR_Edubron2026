library(brms)
library(tidyverse)
library(here)
library(ggdist)

load(
  file = here(
    "Presentations", 
    "WritingData.RData")
)

M3 <- brm(
  SecondVersion ~ FirstVersion_GM + Experimental_condition + (1 + FirstVersion_GM |Class),
  data = WritingData,
  backend = "cmdstanr",
  cores = 4,
  control = list(adapt_delta = 0.9),
  seed = 1975 
)

WritingData <- WritingData %>%
  mutate(
    Control_Condition = 
      case_when(
        Condition == 2 ~ 1,
        Condition == 1 ~ 0
    )
  )



M_alternative <- brm(
  SecondVersion ~ -1 + Control_Condition + Experimental_condition + (1 |Class),
  data = WritingData,
  backend = "cmdstanr",
  cores = 4,
  control = list(adapt_delta = 0.9),
  seed = 1975 
)

summary(M_alternative)


############

posterior_PD <- as_draws_df(M3)

Plot <- ggplot(
  posterior_PD,
  aes(x = b_FirstVersion_GM)
) +
  stat_halfeye()

Plot + scale_y_continuous(name = "", breaks = NULL)

posterior_PD <- posterior_PD %>%
  mutate(
    Exp_Mean_EXPCONDITION = b_Intercept + b_Experimental_condition
  )

Plot <- ggplot(
  posterior_PD,
  aes(x = Exp_Mean_EXPCONDITION)
) +
  stat_halfeye()

Plot + scale_y_continuous(name = "", breaks = NULL)


Plot <- ggplot(
  posterior_PD,
  aes(x = b_Intercept + b_Experimental_condition)
) +
  stat_halfeye()

Plot + scale_y_continuous(name = "", breaks = NULL)

P <- posterior_PD %>% 
  select(
    b_Experimental_condition, b_FirstVersion_GM
  ) %>% 
  pivot_longer(everything())

P
