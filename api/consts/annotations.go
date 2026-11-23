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
	// LabelImage selects every evaluator pod of one function. Its value is the Service name.
	LabelImage = "fn.kpt.dev/image"
	// AnnotationTemplateVersion records the PodTemplate resourceVersion used to build the pod.
	AnnotationTemplateVersion = "fn.kpt.dev/template-version"
	// AnnotationResolvedVersion is the concrete tag the evaluator pod was started with.
	AnnotationResolvedVersion = "fn.kpt.dev/resolved-version"
	// AnnotationPodIndex is the postfix in the pod name. The lowest free index is reused.
	AnnotationPodIndex = "fn.kpt.dev/pod-index"
	// AnnotationFunctionImage is the repository, without tag or digest, the evaluator pod runs.
	AnnotationFunctionImage = "fn.kpt.dev/function-image"
	// AnnotationIdleSince is when the manager first observed the pod with no Claimed request naming it.
	AnnotationIdleSince = "fn.kpt.dev/idle-since"
	// AnnotationErrorSince is when the manager moved a request into an error phase.
	AnnotationErrorSince = "fn.kpt.dev/error-since"
	// AnnotationMatchedPod marks that the request was already told an evaluator can serve it.
	AnnotationMatchedPod = "fn.kpt.dev/matched-pod"
)

// LabelImageKey is set on FunctionPodRequest by clients. Evaluator pods watch requests with the same value.
const LabelImageKey = "fn.kpt.dev/image-key"
