//
// Copyright (C) 2005-2021 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

protocol CameraKitCaptureDelegate: AnyObject {
    /// Notifies the delegate the review session is over and delivers captured asset information.
    /// - Note: It is expected that the receiver copies over any desired disk data as the default capture location should be
    /// cleared out after this call.
    /// - Parameter capturedAsset: captured asset information containing metadata and path information
    func didEndReview(for capturedAsset: CapturedAsset)
    
    /// Notifies the delegate the review session is over and will begin to deliver captured asset information.
    func willStartReview()
}
