// Copyright 2026 The kpt Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package consts

const (
	// EventStarting is recorded when a Function Evaluator Pod is created.
	EventStarting = "StartingPod"
	// EventStartFailed is recorded when a Function Evaluator Pod does not become Ready.
	EventStartFailed = "StartFailed"
	// EventDeletedIdle is recorded when an idle Function Evaluator Pod is deleted.
	EventDeletedIdle = "DeletedIdlePod"
	// EventUnsatisfiable is recorded when no published tag satisfies the constraint.
	EventUnsatisfiable = "UnsatisfiableConstraint"
	// EventReaped is recorded when a request moves to an error phase.
	EventReaped = "RequestReaped"
	// EventPodAvailable is recorded once when an existing evaluator can serve the request.
	EventPodAvailable = "PodAvailable"
)
