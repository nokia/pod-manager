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
	// WrapperServerImageEnv is the environment variable porch uses for the wrapper-server image.
	WrapperServerImageEnv = "WRAPPER_SERVER_IMAGE"
	// EnvFunctionImage is the concrete function image the evaluator pod runs.
	EnvFunctionImage = "FUNCTION_IMAGE"
	// EnvFunctionRepository is the repository without tag, used when FUNCTION_IMAGE is still a placeholder.
	EnvFunctionRepository = "FUNCTION_REPOSITORY"
	// EnvDefaultImagePrefix is prepended to a bare function name.
	EnvDefaultImagePrefix = "DEFAULT_IMAGE_PREFIX"
	// EnvVersion is the concrete tag this evaluator pod was started with.
	EnvVersion = "VERSION"
)

// EnvImageKey is the label value this evaluator pod watches (injected by the Pod Manager).
const EnvImageKey = "IMAGE_KEY"
