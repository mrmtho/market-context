# Market Context — Flutter Responsive Web Frontend Spec

## 1. Product Summary

**Working name:** Market Context  
**Concept:** A responsive Flutter web application that makes asset prices feel “3D” by showing not only the current price, but the economic, company, sector, sentiment, and valuation context around that price across time.

Instead of asking users to interpret isolated charts, the app helps them answer:

- What does this price mean?
- What changed since 3, 6, or 12 months ago?
- What macro conditions existed when the asset traded at this level before?
- Is the asset more expensive, cheaper, or simply different versus prior periods?
- What assumptions does the current price appear to imply?

## 2. Primary Users

### 2.1 Retail Investors
Users who want better context than Google Finance or Yahoo Finance without needing Bloomberg-level complexity.

### 2.2 Analysts and Finance Creators
Users who need quick historical comparisons, narrative explanations, and shareable investment context.

### 2.3 Founders, Operators, and Business Learners
Users who want to understand how macroeconomic conditions affect assets, sectors, and market narratives.

## 3. Product Positioning

**One-liner:** Google Finance, but every price has context.

**Alternative framing:** A financial time machine that shows what the world looked like when an asset was priced at a certain level.

**Core promise:** Turn price charts into explanations, comparisons, and market narratives.

## 4. Platform Scope

### 4.1 Frontend
- Flutter web application.
- Responsive layouts for desktop, tablet, and mobile web.
- Initial target: modern Chromium, Safari, Firefox, and mobile browsers.

### 4.2 Backend Assumption
This document focuses on frontend implementation, but assumes APIs exist or will exist for:

- Asset search.
- Current and historical prices.
- Historical macroeconomic data.
- Company fundamentals.
- News and event timelines.
- AI-generated explanations.
- User watchlists and saved comparisons.

### 4.3 Frontend Architecture
Recommended Flutter stack:

- **State management:** Riverpod or Bloc.
- **Routing:** go_router.
- **Charts:** fl_chart, Syncfusion Flutter Charts, or a custom Canvas/WebGL-style implementation if advanced interactions are needed.
- **Networking:** Dio or http.
- **Data models:** freezed/json_serializable.
- **Design system:** custom component library built around Material 3 foundations.
- **Testing:** flutter_test, golden tests, integration_test.

## 5. Design Principles

1. **Context over data dumping**  
   Every data point should help the user understand meaning, not just add noise.

2. **Time as the organizing layer**  
   Users should be able to move through time and see what changed.

3. **Comparison-first interface**  
   The app should constantly help users compare now versus then.

4. **Progressive disclosure**  
   Start simple, then reveal deeper context only when the user asks for it.

5. **Narrative alongside charts**  
   Charts show movement. Text explains why it may have happened.

6. **Responsive by default**  
   The app must feel native on desktop and usable on mobile web.

## 6. Core User Journeys

### 6.1 Search and Open an Asset
User searches for an asset, opens its page, and sees price plus contextual snapshots.

### 6.2 Compare Current Price with Prior Periods
User compares today with 3 months ago, 6 months ago, 12 months ago, or a custom date.

### 6.3 Click Any Point on the Chart
User clicks a chart point and sees the macro, company, news, and valuation context for that date.

### 6.4 Find the Last Time Asset Traded at This Price
User sees the previous matching price period and compares conditions then versus now.

### 6.5 Understand Price Drivers
User receives an explanation of whether movement was driven by macro, earnings, valuation rerating, sentiment, or sector trends.

### 6.6 Save and Share Insights
User saves a contextual comparison or exports a shareable snapshot.

## 7. Key Data Concepts

### 7.1 Asset
Represents a stock, ETF, cryptoasset, commodity, index, currency pair, or bond yield.

Example fields:

- id
- ticker
- displayName
- assetType
- exchange
- currency
- country
- sector
- industry
- logoUrl

### 7.2 Price Point
Represents asset price at a specific time.

Example fields:

- assetId
- date
- open
- high
- low
- close
- adjustedClose
- volume
- marketCap

### 7.3 Context Snapshot
Represents all relevant data for an asset at a specific date.

Example fields:

- date
- price
- valuationMetrics
- macroMetrics
- fundamentals
- sectorMetrics
- newsEvents
- sentimentSignals
- explanation

### 7.4 Macro Metric
Examples:

- Inflation
- Interest rates
- GDP growth
- Unemployment
- Money supply
- Oil price
- Dollar index
- Bond yields
- Credit spreads

### 7.5 Narrative Event
A significant event linked to price movement.

Example fields:

- date
- title
- source
- category
- impactDirection
- confidence
- summary

## 8. Information Architecture

### 8.1 Main Routes

- `/` — Landing / search-first home.
- `/asset/:symbol` — Asset detail dashboard.
- `/asset/:symbol/context/:date` — Deep context view for a selected date.
- `/compare` — Multi-asset or multi-date comparison workspace.
- `/watchlist` — Saved assets and alerts.
- `/insights/:id` — Saved/shareable insight page.
- `/settings` — User preferences.

### 8.2 Main Navigation

Desktop:

- Search bar
- Explore
- Watchlist
- Compare
- Saved Insights
- Settings

Mobile:

- Search
- Asset
- Compare
- Watchlist
- Menu

## 9. Responsive Layout Strategy

### 9.1 Desktop Layout
- Left sidebar navigation.
- Main chart and context workspace.
- Right-side context panel.
- Multi-column comparison tables.

### 9.2 Tablet Layout
- Top navigation.
- Chart first.
- Context cards stacked below.
- Right panel becomes collapsible drawer.

### 9.3 Mobile Layout
- Search-first interface.
- Chart simplified.
- Context shown as swipeable cards.
- Tables converted into stacked comparison rows.
- Bottom navigation.

## 10. Feature List

1. Responsive App Shell and Navigation
2. Asset Search and Discovery
3. Asset Overview Dashboard
4. Interactive Price Timeline
5. Historical Context Snapshots
6. Time Comparison Engine
7. Macro Context Layer
8. Fundamentals and Valuation Layer
9. News and Events Timeline
10. AI Narrative Explanation Layer
11. Same-Price Historical Comparison
12. Scenario and Assumption Explorer
13. Watchlist and Saved Assets
14. Saved Insights and Sharing
15. Responsive Design System
16. Data Loading, Error, and Empty States
17. User Preferences and Settings
18. Frontend API Client Layer
19. Testing and Quality Assurance
20. Analytics and Product Instrumentation

---

# 11. Feature Specifications and Task Breakdowns

## Feature 1: Responsive App Shell and Navigation

### Goal
Create the base Flutter web shell that supports desktop, tablet, and mobile layouts.

### UX Requirements
- Persistent navigation on desktop.
- Bottom navigation on mobile.
- Search always accessible.
- Smooth responsive transitions.
- Clear active route state.

### 20 Implementation Tasks

1. Create Flutter project structure for web-first application.
2. Configure Material 3 theme foundation.
3. Add go_router dependency and initial route setup.
4. Define route constants for all major screens.
5. Create `AppShell` widget.
6. Create desktop sidebar navigation widget.
7. Create tablet top navigation widget.
8. Create mobile bottom navigation widget.
9. Implement responsive breakpoint utility.
10. Add adaptive layout builder.
11. Create reusable page scaffold wrapper.
12. Implement active navigation state.
13. Add route transition animations.
14. Add global search entry point placeholder.
15. Implement app-wide loading overlay support.
16. Add app-wide error boundary widget.
17. Create navigation item model.
18. Add keyboard navigation basics for web.
19. Write golden tests for desktop/tablet/mobile shell.
20. Validate shell behavior across browser widths.

---

## Feature 2: Asset Search and Discovery

### Goal
Allow users to quickly search and open assets.

### UX Requirements
- Search by ticker, company name, asset type, or exchange.
- Show asset metadata in results.
- Support recent searches.
- Support keyboard selection.
- Work well on mobile.

### 20 Implementation Tasks

1. Define `AssetSearchResult` model.
2. Create search API client method.
3. Create search provider/state controller.
4. Build desktop search input component.
5. Build mobile search full-screen overlay.
6. Add debounced query handling.
7. Add loading indicator inside search results.
8. Add empty state for no matches.
9. Add error state for failed search.
10. Build result row component with ticker, name, type, and exchange.
11. Add asset logo/avatar fallback.
12. Implement keyboard up/down navigation.
13. Implement enter-to-open selected asset.
14. Save recent searches locally.
15. Display recent searches before query input.
16. Add clear recent searches action.
17. Add filter chips for stocks, ETFs, crypto, indices, and commodities.
18. Route selected result to asset dashboard.
19. Add search analytics events.
20. Write unit and widget tests for search behavior.

---

## Feature 3: Asset Overview Dashboard

### Goal
Show the main asset page combining current price, key metrics, and context entry points.

### UX Requirements
- Show current price prominently.
- Show daily movement and percentage change.
- Show contextual summary.
- Provide shortcuts to 3M, 6M, 12M, and custom comparison.
- Present major layers without overwhelming the user.

### 20 Implementation Tasks

1. Define `AssetOverview` data model.
2. Create asset overview API method.
3. Create dashboard state provider.
4. Build asset header widget.
5. Add price display component.
6. Add daily change indicator component.
7. Add market status indicator.
8. Add currency and exchange display.
9. Add responsive dashboard grid.
10. Add current context summary card.
11. Add quick comparison chips for 3M, 6M, 12M, and YTD.
12. Add valuation summary card.
13. Add macro summary card.
14. Add news summary card.
15. Add fundamentals summary card.
16. Add loading skeleton for dashboard.
17. Add failed-load retry state.
18. Add stale-data warning state.
19. Add dashboard refresh action.
20. Write dashboard widget tests.

---

## Feature 4: Interactive Price Timeline

### Goal
Create the main chart experience where users can inspect price movement across time.

### UX Requirements
- Chart should support multiple time ranges.
- Users can hover/click/tap points.
- Selected points drive the context panel.
- Chart should work across screen sizes.
- Chart should avoid clutter.

### 20 Implementation Tasks

1. Define `PriceSeriesPoint` model.
2. Create price history API method.
3. Add time range enum: 1D, 1W, 1M, 3M, 6M, 1Y, 5Y, MAX.
4. Create price timeline provider.
5. Build chart container component.
6. Integrate selected charting library.
7. Render line chart for close price.
8. Add responsive chart height rules.
9. Add hover tooltip for desktop.
10. Add tap tooltip for mobile.
11. Add selected date marker.
12. Add time range selector.
13. Add volume overlay or secondary view.
14. Add event markers on chart.
15. Add loading skeleton for chart.
16. Add no-data chart state.
17. Add chart interaction callback to context panel.
18. Optimize chart rendering for large datasets.
19. Add chart accessibility labels.
20. Write chart interaction tests.

---

## Feature 5: Historical Context Snapshots

### Goal
When a user selects a date, show what the asset and the world looked like at that point.

### UX Requirements
- Date-specific context panel.
- Price, valuation, macro, fundamentals, news, and sentiment together.
- Clear distinction between exact and nearest available data.
- Compact but expandable.

### 20 Implementation Tasks

1. Define `ContextSnapshot` model.
2. Define nested models for macro, valuation, fundamentals, news, and sentiment.
3. Create context snapshot API method.
4. Create selected-date state provider.
5. Create context panel container.
6. Add selected date header.
7. Add price-at-date row.
8. Add nearest-data warning display.
9. Add valuation mini-card.
10. Add macro mini-card.
11. Add fundamentals mini-card.
12. Add news mini-card.
13. Add sentiment mini-card.
14. Add expandable sections.
15. Add mobile bottom sheet version.
16. Add desktop right-panel version.
17. Add loading state for snapshot fetch.
18. Add snapshot error state.
19. Cache selected snapshots in memory.
20. Write context panel widget tests.

---

## Feature 6: Time Comparison Engine

### Goal
Compare today against previous time periods or custom dates.

### UX Requirements
- Support 3M, 6M, 12M, YTD, and custom date comparisons.
- Show side-by-side values.
- Highlight meaningful changes.
- Summarize the biggest differences.

### 20 Implementation Tasks

1. Define `ComparisonPeriod` model.
2. Define `ContextComparison` model.
3. Create comparison API method.
4. Create comparison provider.
5. Build comparison period selector.
6. Add predefined period chips.
7. Add custom date picker.
8. Build desktop comparison table.
9. Build mobile stacked comparison cards.
10. Add difference calculation display.
11. Add percentage change display.
12. Add positive/negative/neutral change semantics.
13. Add top differences summary card.
14. Add support for comparing more than two dates.
15. Add loading skeleton.
16. Add empty comparison state.
17. Add failed comparison retry state.
18. Add export comparison callback placeholder.
19. Add analytics events for selected periods.
20. Write tests for comparison rendering.

---

## Feature 7: Macro Context Layer

### Goal
Show macroeconomic conditions linked to asset price points.

### UX Requirements
- Inflation, rates, GDP, unemployment, bond yields, oil, dollar index, and other relevant macro data.
- Show values for current and selected historical periods.
- Explain why each macro variable may matter.
- Avoid overwhelming users.

### 20 Implementation Tasks

1. Define `MacroMetric` model.
2. Define macro metric categories.
3. Create macro context API method.
4. Create macro context provider.
5. Build macro summary card.
6. Build macro metric row component.
7. Add metric value formatting rules.
8. Add date-aligned metric display.
9. Add nearest available macro data indicator.
10. Add macro comparison table.
11. Add mini sparkline for each metric.
12. Add metric explanation tooltip.
13. Add macro importance labels.
14. Add country/region selector placeholder.
15. Add macro data source display.
16. Add loading state.
17. Add missing data state.
18. Add macro layer expansion panel.
19. Add tests for metric formatting.
20. Add widget tests for macro layer.

---

## Feature 8: Fundamentals and Valuation Layer

### Goal
Show business and valuation conditions at each price point.

### UX Requirements
- Revenue, earnings, margins, cash flow, PE, PS, EV/EBITDA, and market cap.
- Compare fundamentals then versus now.
- Make it clear whether price moved because business changed or valuation changed.

### 20 Implementation Tasks

1. Define `FundamentalMetric` model.
2. Define `ValuationMetric` model.
3. Create fundamentals API method.
4. Create valuation API method.
5. Create combined fundamentals provider.
6. Build fundamentals summary card.
7. Build valuation summary card.
8. Add metric formatting utility.
9. Add fiscal period labeling.
10. Add trailing-twelve-month display support.
11. Add quarterly data display support.
12. Add historical valuation comparison table.
13. Add business growth comparison card.
14. Add valuation rerating explanation placeholder.
15. Add expandable metric definitions.
16. Add data source labels.
17. Add missing-fundamentals state for non-equity assets.
18. Add loading skeleton.
19. Add error state.
20. Write tests for valuation/fundamental displays.

---

## Feature 9: News and Events Timeline

### Goal
Show key events that happened around major price movements.

### UX Requirements
- Timeline of relevant news and events.
- Events attached to dates and chart markers.
- Categories like earnings, macro, regulation, product, analyst, geopolitical, sector.
- Concise summaries.

### 20 Implementation Tasks

1. Define `NarrativeEvent` model.
2. Define event category enum.
3. Create events API method.
4. Create events provider.
5. Build timeline component.
6. Build event card component.
7. Add event category icons.
8. Add event impact direction indicator.
9. Add event confidence indicator.
10. Add source display.
11. Add external link handling placeholder.
12. Add date grouping.
13. Add event filtering by category.
14. Add chart marker integration.
15. Add selected chart date event highlighting.
16. Add empty events state.
17. Add loading skeleton.
18. Add event fetch error state.
19. Add analytics event for event click.
20. Write timeline widget tests.

---

## Feature 10: AI Narrative Explanation Layer

### Goal
Translate price movement and context changes into readable explanations.

### UX Requirements
- Plain-language summaries.
- Show likely drivers, not unsupported certainty.
- Link explanation claims to data points.
- Let users expand into deeper reasoning.

### 20 Implementation Tasks

1. Define `NarrativeExplanation` model.
2. Define explanation sections: summary, drivers, caveats, data references.
3. Create explanation API method.
4. Create explanation provider.
5. Build narrative summary card.
6. Build driver breakdown component.
7. Add confidence labels.
8. Add caveat section.
9. Add referenced data chips.
10. Add expandable long-form explanation.
11. Add regenerate explanation action placeholder.
12. Add explanation loading state.
13. Add explanation unavailable state.
14. Add explanation error state.
15. Add safety copy for non-advice disclaimer.
16. Add source trace display.
17. Add copy explanation action.
18. Add share explanation action placeholder.
19. Add feedback buttons for explanation quality.
20. Write tests for narrative layer rendering.

---

## Feature 11: Same-Price Historical Comparison

### Goal
Show the last time an asset traded near today’s price and compare conditions then versus now.

### UX Requirements
- Identify previous matching price periods.
- Compare today with that prior period.
- Show how the same price can mean different things.
- Make this a flagship “3D price” feature.

### 20 Implementation Tasks

1. Define `SamePriceMatch` model.
2. Define price matching tolerance rules.
3. Create same-price API method.
4. Create same-price provider.
5. Build same-price feature card.
6. Add current price display.
7. Add previous matching date display.
8. Add previous matching price display.
9. Add tolerance explanation tooltip.
10. Add then-versus-now comparison table.
11. Add macro comparison section.
12. Add valuation comparison section.
13. Add fundamentals comparison section.
14. Add news comparison section.
15. Add headline insight summary.
16. Add loading state.
17. Add no-match state.
18. Add error state.
19. Add route to detailed comparison view.
20. Write tests for same-price comparison UI.

---

## Feature 12: Scenario and Assumption Explorer

### Goal
Let users explore how changing assumptions may affect implied value or interpretation.

### UX Requirements
- Show scenario inputs for growth, rates, margins, valuation multiple, and macro conditions.
- Display implied directional impact.
- Make it educational, not financial advice.

### 20 Implementation Tasks

1. Define `ScenarioInput` model.
2. Define `ScenarioResult` model.
3. Create scenario API method placeholder.
4. Create scenario state provider.
5. Build scenario explorer screen.
6. Build assumption slider component.
7. Build numeric assumption input component.
8. Add default base case scenario.
9. Add bull case scenario.
10. Add bear case scenario.
11. Add custom scenario support.
12. Add implied value result card.
13. Add sensitivity table.
14. Add assumptions summary card.
15. Add disclaimer copy.
16. Add reset scenario action.
17. Add save scenario placeholder.
18. Add loading state.
19. Add error state.
20. Write scenario UI tests.

---

## Feature 13: Watchlist and Saved Assets

### Goal
Allow users to save assets and quickly revisit contextual dashboards.

### UX Requirements
- Add/remove asset from watchlist.
- Show current price and context status.
- Support simple grouping later.
- Responsive watchlist view.

### 20 Implementation Tasks

1. Define `WatchlistItem` model.
2. Create watchlist API methods.
3. Create local fallback watchlist storage.
4. Create watchlist provider.
5. Add watchlist button to asset header.
6. Build watchlist page.
7. Build watchlist row component.
8. Build mobile watchlist card component.
9. Add remove from watchlist action.
10. Add empty watchlist state.
11. Add loading state.
12. Add failed-load state.
13. Add sort by ticker.
14. Add sort by price change.
15. Add sort by recently viewed.
16. Add context alert badge placeholder.
17. Add quick open action.
18. Add optimistic updates.
19. Add analytics events.
20. Write watchlist tests.

---

## Feature 14: Saved Insights and Sharing

### Goal
Allow users to save or share a contextual snapshot/comparison.

### UX Requirements
- Save selected asset/date/comparison.
- Generate shareable insight page.
- Support copy link and image export later.
- Preserve enough data to make insight understandable.

### 20 Implementation Tasks

1. Define `SavedInsight` model.
2. Create save insight API method.
3. Create load insight API method.
4. Create saved insights provider.
5. Add save insight button to context panel.
6. Add save insight button to comparison view.
7. Build saved insights page.
8. Build insight card component.
9. Build public/shared insight route.
10. Add copy link action.
11. Add share sheet placeholder for mobile.
12. Add export image placeholder.
13. Add delete saved insight action.
14. Add empty saved insights state.
15. Add loading state.
16. Add error state.
17. Add insight metadata display.
18. Add saved timestamp display.
19. Add analytics events.
20. Write saved insight tests.

---

## Feature 15: Responsive Design System

### Goal
Create a reusable UI component system for the app.

### UX Requirements
- Consistent spacing, typography, colors, cards, buttons, and tables.
- Financial data formatting consistency.
- Components adapt across breakpoints.

### 20 Implementation Tasks

1. Define design tokens for spacing.
2. Define typography scale.
3. Define color roles.
4. Define semantic colors for positive, negative, neutral, warning, and info.
5. Create app theme extension.
6. Build primary button component.
7. Build secondary button component.
8. Build icon button component.
9. Build card component.
10. Build metric tile component.
11. Build comparison row component.
12. Build responsive table component.
13. Build loading skeleton component.
14. Build empty state component.
15. Build error state component.
16. Build tooltip/help component.
17. Build chip component.
18. Build badge component.
19. Create component showcase route.
20. Add golden tests for core components.

---

## Feature 16: Data Loading, Error, and Empty States

### Goal
Make the app resilient when APIs are slow, incomplete, or unavailable.

### UX Requirements
- Clear loading states.
- Helpful errors.
- Retry actions.
- Partial data support.
- Stale data warnings.

### 20 Implementation Tasks

1. Define common async state pattern.
2. Create reusable loading skeletons.
3. Create reusable error panel.
4. Create reusable empty state.
5. Create stale data banner.
6. Add retry callback pattern.
7. Add partial data warning pattern.
8. Add network timeout handling.
9. Add unauthorized state placeholder.
10. Add rate limit state placeholder.
11. Add maintenance state placeholder.
12. Add offline detection placeholder.
13. Add global snackbar/toast service.
14. Add error logging hook placeholder.
15. Standardize API error model.
16. Standardize UI error mapping.
17. Add tests for error states.
18. Add tests for loading states.
19. Add tests for empty states.
20. Document state usage guidelines.

---

## Feature 17: User Preferences and Settings

### Goal
Let users customize display preferences.

### UX Requirements
- Currency preference.
- Default chart range.
- Theme preference.
- Region/country macro preference.
- Data density preference.

### 20 Implementation Tasks

1. Define `UserPreferences` model.
2. Create preferences provider.
3. Add local persistence for preferences.
4. Build settings page.
5. Add theme mode selector.
6. Add default currency selector.
7. Add default chart range selector.
8. Add macro region selector.
9. Add data density selector.
10. Add reset preferences action.
11. Apply theme preference app-wide.
12. Apply currency formatting preference.
13. Apply default chart range preference.
14. Apply data density preference to cards/tables.
15. Add settings loading state.
16. Add settings save confirmation.
17. Add settings error state.
18. Add validation for preference values.
19. Add analytics events.
20. Write settings tests.

---

## Feature 18: Frontend API Client Layer

### Goal
Create a clean data access layer between Flutter UI and backend APIs.

### UX Requirements
This is mostly technical, but must enable fast, reliable, testable UI development.

### 20 Implementation Tasks

1. Define API base configuration.
2. Add Dio or http client.
3. Add request timeout configuration.
4. Add response parsing utilities.
5. Add standardized API error handling.
6. Add typed models using freezed/json_serializable.
7. Add asset search endpoint client.
8. Add asset overview endpoint client.
9. Add price history endpoint client.
10. Add context snapshot endpoint client.
11. Add comparison endpoint client.
12. Add macro endpoint client.
13. Add fundamentals endpoint client.
14. Add events endpoint client.
15. Add narrative endpoint client.
16. Add watchlist endpoint client.
17. Add saved insight endpoint client.
18. Add mock API implementation.
19. Add repository layer abstractions.
20. Write API client unit tests.

---

## Feature 19: Testing and Quality Assurance

### Goal
Ensure the frontend is stable, responsive, and safe to iterate on.

### UX Requirements
- Avoid visual regressions.
- Ensure core flows work.
- Validate responsive layouts.
- Catch data formatting bugs.

### 20 Implementation Tasks

1. Set up Flutter test configuration.
2. Set up golden test configuration.
3. Set up integration test configuration.
4. Add mock data fixtures.
5. Add test helpers for responsive sizes.
6. Test app shell navigation.
7. Test search flow.
8. Test asset dashboard loading.
9. Test chart time range selection.
10. Test context snapshot selection.
11. Test comparison rendering.
12. Test macro layer rendering.
13. Test fundamentals layer rendering.
14. Test news timeline rendering.
15. Test same-price comparison rendering.
16. Test watchlist add/remove.
17. Test saved insight flow.
18. Test settings changes.
19. Add accessibility checks where possible.
20. Add CI test command documentation.

---

## Feature 20: Analytics and Product Instrumentation

### Goal
Measure whether users understand and use the context features.

### UX Requirements
- Track product usage without making the app feel invasive.
- Capture key learning moments.
- Help identify confusing areas.

### 20 Implementation Tasks

1. Define analytics event naming convention.
2. Create analytics service abstraction.
3. Add no-op analytics implementation for development.
4. Add production analytics adapter placeholder.
5. Track asset search submitted.
6. Track asset opened.
7. Track chart date selected.
8. Track time range changed.
9. Track comparison period selected.
10. Track context layer expanded.
11. Track same-price comparison opened.
12. Track scenario explorer opened.
13. Track watchlist add/remove.
14. Track insight saved.
15. Track insight shared.
16. Track explanation feedback.
17. Track failed API states.
18. Add privacy-safe payload guidelines.
19. Add analytics debug logger.
20. Document analytics implementation.

---

# 12. MVP Recommendation

The first build should focus on proving the core “price in context” experience.

## MVP Feature Set

1. Responsive App Shell and Navigation
2. Asset Search and Discovery
3. Asset Overview Dashboard
4. Interactive Price Timeline
5. Historical Context Snapshots
6. Time Comparison Engine
7. Macro Context Layer
8. Fundamentals and Valuation Layer
9. AI Narrative Explanation Layer
10. Same-Price Historical Comparison
11. Frontend API Client Layer
12. Data Loading, Error, and Empty States

## MVP Success Criteria

The MVP is successful if a user can:

1. Search for an asset.
2. Open its dashboard.
3. See current price and current context.
4. Compare today with 3M, 6M, and 12M ago.
5. Click a chart point and see historical context.
6. See macro and valuation differences.
7. Understand a plain-language explanation of what changed.
8. See the last time the asset traded near the current price.

---

# 13. Suggested Development Phases

## Phase 1: Foundation
- App shell
- Routing
- Design system
- API client layer
- Mock data
- Loading/error states

## Phase 2: Core Asset Experience
- Search
- Asset dashboard
- Price timeline
- Overview cards

## Phase 3: Context Engine UI
- Context snapshots
- Time comparison
- Macro layer
- Fundamentals layer

## Phase 4: Differentiating Features
- Same-price comparison
- AI narrative explanations
- News/events timeline

## Phase 5: Retention and Sharing
- Watchlist
- Saved insights
- Sharing
- Analytics
- Settings

---

# 14. Example Screen Composition

## 14.1 Asset Dashboard Desktop

Top:

- Asset name, ticker, exchange
- Current price
- Daily movement
- Watchlist button

Main left:

- Interactive price chart
- Time range selector
- Event markers

Main right:

- Selected date context panel
- Current macro snapshot
- Current valuation snapshot
- Narrative explanation

Below:

- Then-versus-now comparison
- Same-price historical comparison
- News/events timeline

## 14.2 Asset Dashboard Mobile

Top:

- Search bar
- Asset header
- Current price

Middle:

- Compact chart
- Time range chips

Bottom:

- Swipeable cards:
  - Context
  - Macro
  - Valuation
  - Explanation
  - Same-price comparison
  - News

---

# 15. Data Display Guidelines

## 15.1 Price Data
Always show:

- Value
- Currency
- Date/time
- Percent change where relevant

## 15.2 Macro Data
Always show:

- Metric name
- Value
- Date
- Region
- Data freshness or nearest available date if not exact

## 15.3 Fundamental Data
Always show:

- Fiscal period
- Trailing or quarterly basis
- Currency where relevant
- Whether data is reported or estimated

## 15.4 AI Explanation Data
Always show:

- Confidence or framing language
- Caveats
- Referenced data points
- Non-advice disclaimer

---

# 16. Non-Goals for Initial Frontend

The first version should not attempt to include:

- Full trading functionality.
- Brokerage integrations.
- Portfolio tax reporting.
- Real-time order book data.
- Complex options analytics.
- Social feeds.
- Fully custom financial modeling engine.

---

# 17. Open Questions

1. Which asset classes should be supported first: equities only, or equities plus crypto/indices?
2. Which market should launch first: US, South Africa, global, or user-selectable?
3. Should AI explanations be generated server-side only?
4. Should shared insights be public by default or private by default?
5. What data providers will be used for prices, macro, fundamentals, and news?
6. How much historical data should the free tier support?
7. Should the app require login for watchlists and saved insights?
8. Should the UI lean more toward professional finance or consumer-friendly education?
9. How should confidence be represented without creating false precision?
10. What regulatory disclaimers are required by target markets?

---

# 18. Recommended First Sprint

## Sprint Goal
Build a mocked but convincing asset dashboard that demonstrates “price in context.”

## Sprint Tasks

1. Create Flutter web project.
2. Add routing and responsive shell.
3. Create design tokens and theme.
4. Build mock asset search.
5. Build asset dashboard route.
6. Build asset header.
7. Build mock price chart.
8. Add time range selector.
9. Add context snapshot panel.
10. Add 3M/6M/12M comparison cards.
11. Add macro context card.
12. Add valuation context card.
13. Add AI explanation mock card.
14. Add same-price comparison mock card.
15. Add responsive mobile layout.
16. Add loading skeletons.
17. Add empty/error placeholders.
18. Add core widget tests.
19. Add sample data fixtures.
20. Deploy preview build.

---

# 19. Product North Star

The product should make users feel this:

> I no longer see a price as a flat number. I see the conditions, assumptions, and story behind it.

That is the “3D market price” experience.
