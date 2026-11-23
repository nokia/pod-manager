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
	// DefaultNamespace is the function namespace porch uses for evaluator pods.
	DefaultNamespace = "porch-fn-system"
	// PlaceholderFunctionImage is the porch PodTemplate stand-in replaced at pod creation.
	PlaceholderFunctionImage = "image-replaced-by-kpt-func-image"

	// ContainerFunction is the KRM function container name in the base pod template.
	ContainerFunction = "function"
	// ContainerInit is the init container that copies the wrapper server.
	ContainerInit = "copy-wrapper-server"

	// BasePodTemplateName is the PodTemplate created when none exists.
	BasePodTemplateName = "base-pod-template"
	// BaseServiceTemplateName is the ServiceTemplate created when none exists.
	BaseServiceTemplateName = "base-service-template"

	// FieldManager is the field manager used for pods and Services.
	FieldManager = "function-pod-manager"
	// LeaderElectionID is the lease name for the single active manager.
	LeaderElectionID = "function-pod-manager"

	LatestTag = "latest"
)
